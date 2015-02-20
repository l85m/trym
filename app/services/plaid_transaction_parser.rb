class PlaidTransactionParser
  attr_reader :charge_list

  def initialize(transaction_request_id)
    @transaction_request = TransactionRequest.find(transaction_request_id)
    @link = @transaction_request.linked_account
    create_charge_list
    if @charge_list.select{ |c| c[:new_transaction] }.present?
      parse 
    else
      @charge_list = nil
    end
  end

  def parse
    group_charges_by_description
    match_to_merchants
    remove_old_charges
    calculate_recurring_score
    create_attributes_for_charges
    consolidate_by_merchant_id
    exclude_items_below_threshold(-2)
  end

  private

  def exclude_items_below_threshold(threshold)
    @charge_list.reject!{ |c| c[:recurring_score] < threshold }
  end

  def create_charge_list
    @charge_list = @transaction_request.data.collect{ |t| t.collect{ |k,v| [k.to_sym,v] }.to_h }
    
    all_transactions = (@transaction_request.previous_transactions + @charge_list).uniq{ |c| c[:_id] }
    new_transaction_ids = (@charge_list - @transaction_request.previous_transactions).collect{ |c| c[:_id] }

    @charge_list = all_transactions.collect{ |c| c.merge( {new_transaction: new_transaction_ids.include?(c[:_id])} ) }
  end

  def create_attributes_for_charges
    @charge_list.each do |charge|
      charge[:history] = charge[:date].zip(charge[:amount]).sort_by{ |d,v| d }.to_h
      charge[:amount] = (charge[:history].values.last * 100).to_i
      charge[:billing_day] = charge[:date].max
      charge[:renewal_period_in_weeks] = round_to_months( distance_between_last_two_dates(charge[:date]) / 7 )
    end
  end

  def group_charges_by_description
    completed_list = []
    grouped_list = []

    @charge_list.each do |item|
      charge = item.deep_dup
      next if completed_list.include?(charge[:name])
      completed_list << charge[:name]      
      charge[:amount] = []
      charge[:date] = []
      
      @charge_list.each do |sibling| 
        if charge[:name].present?
          if charge[:name] == sibling[:name]
            charge[:amount] << sibling[:amount]
            charge[:date] << Date.parse(sibling[:date])
            charge[:new_transaction] = (charge[:new_transaction] || sibling[:new_transaction])
            completed_list << sibling[:name]
          end
        end
      end
      grouped_list << charge
    end
    @charge_list = grouped_list.select{ |c| c[:new_transaction] }
  end

  def remove_old_charges
    @charge_list.reject! do |c|
      dates = c[:date].sort
      dates.max < 12.months.ago && distance_between_last_two_dates(dates).between?(350,380)
    end
  end

  def calculate_recurring_score
    @charge_list.map do |c|
      c[:recurring_score] = TransactionScorer.new(c).calculate_recurring_score
      c[:recurring] = true if ( c[:recurring_score] > 4 && c[:merchant_id].present? )
    end
  end

  def consolidate_by_merchant_id
    sorted_list = @charge_list.sort_by{ |x| x[:recurring_score] }.reverse
    no_merch = sorted_list.select{ |c| c[:merchant_id].nil? }
    with_merch = sorted_list.uniq{ |c| c[:merchant_id] }
    
    (@charge_list - with_merch).each do |c|
      if c[:merchant_id].present?
        index = with_merch.index(with_merch.select{ |x| x[:merchant_id] == c[:merchant_id] }.first)
        with_merch[index][:amount] << c[:amount]
        with_merch[index][:date] << c[:date]
        with_merch[index][:history] = with_merch[index][:history].merge(c[:history])
      end
    end

    @charge_list = (no_merch + with_merch).uniq{ |c| c[:name] }
  end

  def distance_between_last_two_dates(dates)
    return 0 unless dates.size > 1
    dates.sort[-2..-1].reverse.inject(:-).to_i
  end

  def round_to_months(weeks)
    if weeks.floor.remainder(4.0) == 0
      weeks.floor
    elsif weeks.ceil.remainder(4.0) == 0
      weeks.ceil
    else
      weeks
    end
  end

  def match_to_merchants
    @charge_list.map do |c| 
      match = Merchant.find_by_fuzzy_name_with_similar_threshold(c[:name])
      c[:merchant_id] = match.id if match.present?
    end
  end


end