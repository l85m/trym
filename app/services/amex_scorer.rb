class AmexScorer

  def initialize(charge_list)
    @charge_list = charge_list.map{ |c| c[:recurring_score] = 0 }
    @merchant_names = Merchant.pluck(:name).uniq.map(&:downcase)
    group_charges_by_description
    match_to_merchants
    calculate_recurring_score
  end

  def group_charges_by_description
    completed_list = []
    grouped_list = []

    @charge_list.each do |item|
      charge = item.deep_dup
      next if completed_list.include?(charge[:description])
      completed_list << charge[:description]      
      charge[:amount] = []
      charge[:date] = []
      
      @charge_list.each do |sibling| 
        next if charge == sibling
        if charge[:description].size > 5 && sibling[:description].size > 5
          if charge[:description].similar( sibling[:description] ) >= 80
            charge[:amount] << sibling[:amount]
            charge[:date] << sibling[:date]
            completed_list << sibling[:description]
          end
        elsif charge[:description] == sibling[:description]
          charge[:amount] << sibling[:amount]
          charge[:date] << sibling[:date]
          completed_list << sibling[:description]
        end
      end      
      grouped_list << charge
    end

    grouped_list
  end

  def calculate_recurring_score
    @charge_list.map do |c|
      
      if amex_charge?(c)
        c[:recurring_score] = 10 if c[:description].downcase.include?("membership")
      else  
        if c[:date].size > 1
          c[:recurring_score] += 2 if (uniform_distance_between_dates(c[:date]) > 6)
          c[:recurring_score] += 2 if (dates_are_weekly?(c[:date]) || dates_are_monthly?(c[:date]))
          c[:recurring_score] += 2 if amounts_are_similar(c[:amount])
        end
        c[:recurring_score] += 1 if likely_category?( c[:categories] )
        c[:recurring_score] += 2 if likely_subcategory?( c[:categories] )
        c[:recurring_score] -= 2 if unlikely_subcategory?( c[:categories] )
        c[:recurring_score] += 1 if c[:merchant].present?
      end
    end
    @charge_list.sort_by{ |x| x[:recurring_score] }.reverse
  end

  def dates_are_weekly?(dates)
    weeks = dates.collect{ |d| d.strftime("%U").to_i }.compact.uniq
    (weeks.sort[-1] - weeks.sort[0]) == (weeks.size - 1)
  end

  def dates_are_monthly?(dates)
    weeks = dates.collect{ |d| d.strftime("%-m").to_i }.compact.uniq
    (weeks.sort[-1] - weeks.sort[0]) == (weeks.size - 1)
  end

  def uniform_distance_between_dates(dates)
    distance = nil
    if dates.size > 2
      
      dates.sort.each_with_index do |date, i|  
        next_date = dates[i+1]
        return distance if next_date.nil?
        
        if distance.nil? || distance == (next_date - date).to_i
          distance = (next_date - date).to_i
          return 0 if distance == 0
        else
          return 0
        end
      end
    
    else
      return 0
    end
  end

  def amounts_are_similar(amounts)
    (amounts.each_cons(2).map{ |a,b| (b-a).abs }.max / amounts.min.to_f) < 0.1
  end

  def match_to_merchants
    @charge_list.map{ |c| c[:merchant] = merchant_recognized?(c[:description]) }
  end

  def amex_charge?(charge)
    charge[:categories].nil?
  end

  def find_merchant(description)
    description = description.downcase
    @merchant_names.uniq.each do |m|
      return m if m.similar(description) > 70 || description.include?(m)
    end
  end

  def unlikely_subcategory?(categories)
    ["bar & café", "taxis & coach", "lodging", "airline", "restaurant", "tolls & fees", "fuel"].include?(categories[1].downcase)
  end

  def likely_category?(categories)
    ["communications", "business services"].include?(categories[0].downcase)
  end

  def likely_subcategory?(categories)
    [
      "internet services", "insurance services", "mobile telecom", "cable & internet comm", 
      "vehicle leasing & purchase", "internet purchase", "music & video", "associations"
    ].include?(categories[1].downcase)
  end

end