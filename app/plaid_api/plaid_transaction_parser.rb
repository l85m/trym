class PlaidTransactionParser
  attr_reader :charge_list

  def initialize(transaction_request_id)
    @transaction_request = TransactionRequest.find(transaction_request_id)
    @link = @transaction_request.linked_account
    create_charge_list
    parse 
  end

  def parse
    group_charges_by_description
    match_to_merchants
    remove_zero_dollar_charges
    calculate_recurring_score_and_renewal_period
    create_attributes_for_charges
  end

  private

  def remove_zero_dollar_charges
    @charge_list.reject!{ |c| c[:amount].inject(:+) <= 0 }
  end

  def create_charge_list
    @charge_list = @transaction_request.data.collect{ |t| t.collect{ |k,v| [k.to_sym,v] }.to_h }
    @charge_list = (@transaction_request.previous_transactions + @charge_list).uniq{ |c| c[:_id] }
  end

  def create_attributes_for_charges
    @charge_list.each do |charge|
      charge[:history] = charge[:date].zip(charge[:amount]).sort_by{ |d,v| d }.to_h
      charge[:amount] = charge[:history][charge[:history].keys.max]
      charge[:billing_day] = charge[:date].max
      charge[:renewal_period_in_weeks] = charge[:interval_in_days] < 10 ? 7 : charge[:interval_in_days] < 20 ? 2 : charge[:interval_in_days] < 40 ? 4 : charge[:interval_in_days] < 100 ? 13 : charge[:interval_in_days] < 200 ? 26 : 52
    end
  end

  def group_charges_by_description
    completed_list = []
    grouped_list = []

    @charge_list.each do |item|      
      next if completed_list.include?(item[:name])

      charge = item.deep_dup
      completed_list << charge[:name]      
      charge[:amount] = []
      charge[:date] = []
      
      @charge_list.each do |sibling| 
        
        if charge[:name].present? && (charge[:name].downcase.similar(sibling[:name].downcase) > 80.0)
          charge[:amount] << sibling[:amount]
          charge[:date] << Date.parse(sibling[:date])
          completed_list << sibling[:name]
        end
      
      end
      grouped_list << charge
    end
    @charge_list = grouped_list
  end

  def calculate_recurring_score_and_renewal_period
    @charge_list.map do |c| 
      scorer = TransactionScorer.new(c, @transaction_request)
      c[:recurring_score] = scorer.score 
      c[:interval_in_days] = scorer.interval
    end
  end

  def match_to_merchants
    @charge_list.map do |c|
      match = Merchant.find_by_fuzzy_name_with_similar_threshold(c[:name])
      if ( !match.present? && c[:meta]["payment_processor"].present? )
        match = Merchant.find_by_fuzzy_name_with_similar_threshold(c[:meta]["payment_processor"]) if c[:meta]["payment_processor"].present?
      elsif ( !match.present? && card_membership_fees.select{ |n| c[:name].downcase.include?(n) }.present? && c[:category_id] == "10000000" )
        match = Merchant.find_by_fuzzy_name_with_similar_threshold(@link.financial_institution.name)
      elsif !match.present?
        match = Merchant.create( name: c[:name], validated: false )
      end
      c[:merchant_id] = match.id if match.present?
    end
  end

  def card_membership_fees
    ["annual membership"]
  end
end