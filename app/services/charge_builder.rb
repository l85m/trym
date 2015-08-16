class ChargeBuilder

	def initialize(transactions)
		return false unless transactions
		@transactions = transactions.order(date: :desc)
		@transaction_request = @transactions.first.transaction_request
		@linked_account = @transaction_request.linked_account
		@user = @transaction_request.linked_account.user
		@plaid_name_to_charge_id = @user.charges.where(merchant_id: nil).pluck(:plaid_name, :id).collect{ |name,id| [normalize_name(name), id] }.to_h
		@merchant_id_to_charge_id = @user.charges.where.not(merchant_id: nil).pluck(:merchant_id, :id).to_h
		
		@existing_charge_transactions_and_charges = @transactions.collect{ |t| map_transactions_to_charges t }.compact
		@trym_category_ids = @transactions.joins(:plaid_category).pluck('transactions.id','plaid_categories.trym_category_id').to_h

		if @existing_charge_transactions_and_charges.present?
			map_transactions_to_existing_charges
			update_existing_charges
		end

		@new_charge_transactions = group_new_charge_transactions

		if @new_charge_transactions.present?
			new_charges = create_new_charges
			update_transactions_belonging_to_new_charges new_charges
		end
	end

	def create_new_charges
		@merchant_cache = {}
		columns = "amount,billing_day,trym_category_id,plaid_name,merchant_id,user_id,renewal_period_in_weeks,recurring_score,recurring,linked_account_id"
		new_charge_sql = @new_charge_transactions.collect do |transactions|
			merchant = get_merchant_if_present(transactions)
			transaction_scorer = TransactionScorer.new transactions, @transaction_request, merchant
			first_transaction = transactions.first
			[
				first_transaction.amount,
				first_transaction.date,
				@trym_category_ids[first_transaction.id],
				first_transaction.name,
			 	merchant.present? ? merchant.id : nil,
			 	@user.id,
			 	normalize_renewal_period(transaction_scorer.interval),
			 	transaction_scorer.score,
			 	transaction_scorer.recurring,
			 	@linked_account.id
			].collect { |c| ar_quote(c) }.join(",")
		end.collect { |c| "(#{c})" }.join(",")
		Charge.where(id: Charge.connection.execute("INSERT INTO charges (#{columns}) VALUES #{new_charge_sql} RETURNING id").values)
	end

	def update_transactions_belonging_to_new_charges(new_charges)
		transaction_update_sql = "SET charge_id = CASE id " + @new_charge_transactions.collect.with_index do |transactions, index|
			transactions.collect{ |transaction| sql_when_then(transaction.id, ar_quote(new_charges[index].id)) }.join(" ")
		end.join(" ") + " END"
		Transaction.connection.execute "UPDATE transactions #{transaction_update_sql} WHERE id IN (#{@new_charge_transactions.flatten.collect{ |t| ar_quote(t.id) }.join(",")})"
	end
	
	def map_transactions_to_existing_charges
		transaction_update_sql = "SET charge_id = CASE id " + @existing_charge_transactions_and_charges.collect do |transaction, charge_id|
			sql_when_then(transaction.id, ar_quote(charge_id))
		end.join(" ") + "END"
		Transaction.connection.execute "UPDATE transactions #{transaction_update_sql} WHERE id IN (#{@existing_charge_transactions_and_charges.map(&:first).collect{ |t| ar_quote(t.id) }.join(",")})"
	end

	def update_existing_charges
		base_columns = [:amount, :billing_day, :recurring_score]
		charges = Charge.where(id: @existing_charge_transactions_and_charges.map(&:last)).collect{ |c| [c.id, c] }.to_h
		@existing_charge_transactions_and_charges = @existing_charge_transactions_and_charges.collect { |transaction,charge_id| [transaction,charges[charge_id]] }
		transactions_to_recurring_charges = @existing_charge_transactions_and_charges.select { |_,charge| charge.recurring  }
		if transactions_to_recurring_charges.present?
			#user has presumably validated these, so we don't want to overwrite their validation
			update_charges transactions_to_recurring_charges, base_columns
		end
		@existing_charge_transactions_and_charges -= transactions_to_recurring_charges
		
		transactions_to_merchantless_charges = @existing_charge_transactions_and_charges.select { |_,charge| charge.merchant_id.nil? }
		if transactions_to_merchantless_charges.present?
			#we can specify a new merchant on charges without merchants if we can find one
			update_charges transactions_to_merchantless_charges, base_columns + [:merchant_id, :recurring, :renewal_period_in_weeks]
		end
		transactions_to_merchantless_charges -= transactions_to_merchantless_charges

		if @existing_charge_transactions_and_charges.present?
			#we don't want to overwrite a merchant, but we can check to see if the existing merchant has updated default attributes
			update_charges @existing_charge_transactions_and_charges, base_columns + [:recurring, :renewal_period_in_weeks]
		end
	end

	def update_charges(transactions_to_charges, columns)
		recurring_charge_sql = {}
		columns.each { |a| recurring_charge_sql[a] = "#{a} = CASE id " }
		transactions_to_charges.each do |transaction, charge|
			scorer = TransactionScorer.new(charge.transactions)
			columns.each do |a| 
				attribute = charge_attribute_accessor(transaction, charge, scorer, a)
				recurring_charge_sql[a] += sql_when_then(charge.id, attribute) if attribute.present?
			end
		end
		columns.each { |a| recurring_charge_sql[a] += "END" }
		attribute_sql = recurring_charge_sql.values.select{ |a| a.include?("THEN") }.join(", ")
		Charge.where(id: Charge.connection.execute("UPDATE charges SET #{attribute_sql} WHERE id IN (#{transactions_to_charges.flatten.collect{ |t| ar_quote(t.id) }.join(",")})"))
	end

	def charge_attribute_accessor(transaction, charge, scorer, attribute)
		case attribute
		when :amount
			ar_quote transaction.amount
		when :recurring_score
			ar_quote scorer.score
		when :billing_day
			"#{ar_quote transaction.date}::date"
		when :merchant_id
			merchant_id = transaction.merchant_id.presence || charge.merchant_id
			merchant_id.present? ? ar_quote(merchant_id) : nil
		when :recurring
			scorer.recurring ? "#{ar_quote(true)}::boolean" : nil
		when :renewal_period_in_weeks
			scorer.interval.present? ? ar_quote(normalize_renewal_period(scorer.interval)) : nil
		else
			nil
		end
	end

	def group_new_charge_transactions
		@transactions.reload
		no_merchant_transactions = @transactions.where(charge_id: nil).where(merchant_id: nil).group_by{ |t| normalize_name(t.name) }.map(&:last)
		merchant_transactions = @transactions.where(charge_id: nil).where.not(merchant_id: nil).group_by(&:merchant_id).map(&:last)
		merchant_transactions + no_merchant_transactions
	end

	def map_transactions_to_charges(transaction)
    if transaction.merchant_id.present? 
      match = @merchant_id_to_charge_id[transaction.merchant_id]
    else 
      match = @plaid_name_to_charge_id[normalize_name(transaction.name)]
    end
    match.present? ? [transaction, match] : nil
  end

  def normalize_renewal_period(days)
    days < 1 ? 4 : days < 10 ? 1 : days < 20 ? 2 : days < 40 ? 4 : days < 100 ? 13 : days < 200 ? 26 : 52
  end

  def ar_quote(thing)
  	ActiveRecord::Base.connection.quote thing
  end

  def sql_when_then(when_attr, then_attr)
  	"WHEN #{when_attr} THEN #{then_attr} "
  end

  def normalize_name(name)
  	name.downcase.downcase.gsub(/[^a-z0-9]*/,"") 
  end

  def get_merchant_if_present(transactions)
    transaction = transactions.find { |t| t.merchant_id.present? }
    if transaction.present?
    	@merchant_cache[transaction.merchant_id].presence || @merchant_cache[transaction.merchant_id] = transaction.merchant    	
    else
    	nil
    end
  end

end