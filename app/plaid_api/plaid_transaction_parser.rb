class PlaidTransactionParser
  attr_reader :charge_list

  def initialize(transaction_request_id)
    @transaction_request = TransactionRequest.find(transaction_request_id)
    @link = @transaction_request.linked_account

    create_charge_list
    parse 

    PlaidMerchantAliasCreator.perform_async(@transaction_request.data, @link.id)
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
      charge[:renewal_period_in_weeks] = charge[:renewal_period_in_weeks].presence || normalize_renewal_period(charge[:interval_in_days])
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
    @merchs = Merchant.validated.pluck(:name,:id).collect{ |name,id| [name.downcase.gsub(/[^0-9a-z ]/i, ''),id] }
    @merch_aliases = MerchantAlias.linked_to_merchant.where( merch_query ).pluck(:alias, :merchant_id).to_h
    
    @charge_list.map do |c|
      merch_id = @merch_aliases[c[:name]]
      match = merch_id.present? ? Merchant.find(merch_id) : find_by_fuzzy_name_with_similar_threshold(c[:name])
      
      if ( !match.present? && c[:meta]["payment_processor"].present? )
        match = find_by_fuzzy_name_with_similar_threshold(c[:meta]["payment_processor"]) if c[:meta]["payment_processor"].present?
      elsif ( !match.present? && card_membership_fees.select{ |n| c[:name].downcase.include?(n) }.present? && c[:category_id] == "10000000" )
        match = find_by_fuzzy_name_with_similar_threshold(@link.financial_institution.name)
      end

      if match.present?
        c[:merchant_id] = match.id
        c[:renewal_period_in_weeks] = match.default_renewal_period
      end
    end
  end

  def find_by_fuzzy_name_with_similar_threshold(query, threshold = 90)
    if query.present?
      query = query.downcase.gsub(/[^0-9a-z ]/i, '')
      @merchs.each.each do |name, id|
        if ( name.similar(query) >= threshold || ( [query.size,name.size].min > 10 && ( query.include?(name) || name.include?(query) ) ) )
          return Merchant.find(id)
        end
      end
    end
    nil
  end

  def card_membership_fees
    ["annual membership"]
  end

  def normalize_renewal_period(days)
    days < 1 ? 4 : days < 10 ? 1 : days < 20 ? 2 : days < 40 ? 4 : days < 100 ? 13 : days < 200 ? 26 : 52
  end

  def merch_query
    {
      alias: @charge_list.map { |c| c[:name] }, 
      financial_institution_id: @link.financial_institution.id
    }
  end
end