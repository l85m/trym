class PlaidTransactionParser
  attr_reader :transaction_list

  def initialize(transaction_data, transaction_request)
    if init_instance_variables(transaction_data, transaction_request)
      create_transactions_from_plaid
      PlaidMerchantAliasCreator.new(@transaction_list) if @transaction_list.present?
    end
  end

  def init_instance_variables(transaction_data, transaction_request)
    @transaction_request = transaction_request
    @linked_account = @transaction_request.linked_account
    @transaction_data = filter_transaction_data transaction_data
    return false unless @transaction_data.present?
    @merchant_aliases = map_merchant_alias
    @charge_to_merc_id = @linked_account.user.charges.where.not(merchant_id: nil).pluck(:merchant_id, :id).to_h
    @charge_to_plaid_name = @linked_account.user.charges.where.not(plaid_name: nil).pluck(:plaid_name, :id).to_h
    @merchant_id_map = Merchant.validated.pluck(:name, :id).map{ |merchant,id| [normalize_name(merchant),id] }.to_h
    true
  end

  def filter_transaction_data(transaction_data)
    existing_ids = @linked_account.transactions.pluck('transactions.plaid_id')
    transaction_data.reject { |t| existing_ids.include?(t["_id"]) || t["amount"] <= 0 }
  end

  def create_transactions_from_plaid
    columns = "plaid_id, name, date, amount, category_id, merchant_id, transaction_request_id"
    transaction_update_sql = @transaction_data.collect do |t|
      build_sql_value_statement(t)
    end.join(",")
    @transaction_list = Transaction.where(id: Transaction.connection.execute("INSERT INTO transactions (#{columns}) VALUES #{transaction_update_sql} RETURNING id").values)
  end

  def build_sql_value_statement(data)
    merc = @merchant_aliases[data["name"]].presence || map_to_merchant(data)
    amount = data["amount"].present? ? (data["amount"].to_f * 100).to_i : 0
    category = data["category_id"]
    datum = [data["_id"], data["name"], data["date"], amount, category, merc, @transaction_request.id]

    "(#{datum.collect{ |s| s.present? ? ActiveRecord::Base.connection.quote(s) : 'NULL' }.join(',')})"
  end

  def map_merchant_alias
    names = @transaction_data.map{ |t| t["name"] }
    merch_query = { financial_institution_id: @linked_account.financial_institution_id, alias: names }
    MerchantAlias.linked_to_merchant.where( merch_query ).pluck(:alias, :merchant_id).to_h
  end

  def map_to_merchant(t_data)
    [t_data["name"], t_data["meta"]["payment_processor"]].compact.each do |name|
      name = normalize_name name
      return @merchant_id_map[name] if @merchant_id_map.has_key?(name)
    end
    nil
  end
  
  def normalize_name(name)
    name.present? ? name.downcase.downcase.gsub(/[^a-z0-9]*/,"") : nil
  end

end