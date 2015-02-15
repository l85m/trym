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
    calculate_recurring_score
    create_attributes_for_charges
  end

  private

  def create_charge_list
    @charge_list = @transaction_request.data.collect{ |t| t.collect{ |k,v| [k.to_sym,v] }.to_h.merge({ new_transaction: true }) }
    @charge_list = @charge_list + @transaction_request.previous_transactions
    @charge_list.uniq!
  end

  def create_attributes_for_charges
    @charge_list.each do |charge|
      charge[:amount] = ((charge[:amount].sum / charge[:amount].size) * 100).to_i
      charge[:billing_day] = charge[:date].max
      charge[:renewal_period_in_weeks] = round_to_months( average_distance_between_dates(charge[:date]) / 7 )
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
        next if charge == sibling
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

  def calculate_recurring_score
    @charge_list.map do |c|
      c[:recurring_score] = 0
      if c[:date].size > 1
        c[:recurring_score] += 2 if (uniform_distance_between_dates(c[:date]) > 6)
        c[:recurring_score] += 2 if (dates_are_weekly?(c[:date]) || dates_are_monthly?(c[:date]))
        c[:recurring_score] += 2 if amounts_are_similar(c[:amount])
      end
      
      c[:recurring_score] += 1 if likely_category?( c[:category_id] )
      c[:recurring_score] += 2 if very_likely_category?( c[:category_id] )
      
      c[:recurring_score] -= 1 if unlikely_category?( c[:category_id] )
      c[:recurring_score] -= 2 if very_unlikely_category?( c[:category_id] )
      
      c[:recurring_score] += 2 if c[:merchant_id].present?
      c[:recurring] = true if ( c[:recurring_score] > 4 && c[:merchant_id].present? )
    end    
  end

  def dates_are_weekly?(dates)
    weeks = dates.collect{ |d| d.strftime("%U").to_i }.compact.uniq
    (weeks.sort[-1] - weeks.sort[0]) == (weeks.size - 1)
  end

  def dates_are_monthly?(dates)
    weeks = dates.collect{ |d| d.strftime("%-m").to_i }.compact.uniq
    (weeks.sort[-1] - weeks.sort[0]) == (weeks.size - 1)
  end

  def average_distance_between_dates(dates)
    return 0 unless dates.size > 1
    dates.sort.each_cons(2).map{ |a,b| b-a }.inject(:+) / (dates.size - 1).to_f
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

  def round_to_months(weeks)
    if weeks.floor.remainder(4.0) == 0
      weeks.floor
    elsif weeks.ceil.remainder(4.0) == 0
      weeks.ceil
    else
      weeks
    end
  end
      
  def amounts_are_similar(amounts)
    (amounts.each_cons(2).map{ |a,b| (b-a).abs }.max / amounts.min.to_f) < 0.1
  end

  def match_to_merchants
    @charge_list.map do |c| 
      match = Merchant.find_by_fuzzy_name_with_similar_threshold(c[:name])
      c[:merchant_id] = match.id if match.present?
    end
  end

  def amex_charge?(charge)
    charge[:categories].nil?
  end

  def very_unlikely_category?(category_id)
    [
      "13001000","13001001","13001002","13001003","13002000","13003000","13004000","13004001","13004002","13004003","13004004",
      "13004005","13004006","13005000","13005001","13005002","13005003","13005004","13005005","13005006","13005007","13005008",
      "13005009","13005010","13005011","13005012","13005013","13005014","13005015","13005016","13005017","13005018","13005019",
      "13005020","13005021","13005022","13005023","13005024","13005025","13005026","13005027","13005028","13005029","13005030",
      "13005031","13005032","13005033","13005034","13005035","13005036","13005037","13005038","13005039","13005040","13005041",
      "13005042","13005043","13005044","13005045","13005046","13005047","13005048","13005049","13005050","13005051","13005052",
      "13005053","13005054","13005055","13005056","13005057","13005058","13005059","15000000","16000000","16001000","18003000",
      "18006001","18006002","21000000","21001000","21002000","21003000","21004000","21005000","21006000","21007000","21007001",
      "21007002","21008000","21009000","21009001","21010000","21010001","21010002","21010003","21010004","21010005","21010006",
      "21010007","21011000","21012000","21012001","21012002"
    ].include?(category_id)
  end

  def unlikely_category?(category_id)
    [
      "10001000","10002000","11000000","12001000","12004000","12009000","12010000","12016000","13000000","13001000","13001001",
      "13001002","13001003","13002000","13003000","13004000","13004001","13004002","13004003","13004004","13004005","13004006",
      "13005000","13005001","13005002","13005003","13005004","13005005","13005006","13005007","13005008","13005009","13005010",
      "13005011","13005012","13005013","13005014","13005015","13005016","13005017","13005018","13005019","13005020","13005021",
      "13005022","13005023","13005024","13005025","13005026","13005027","13005028","13005029","13005030","13005031","13005032",
      "13005033","13005034","13005035","13005036","13005037","13005038","13005039","13005040","13005041","13005042","13005043",
      "13005044","13005045","13005046","13005047","13005048","13005049","13005050","13005051","13005052","13005053","13005054",
      "13005055","13005056","13005057","13005058","13005059","15000000","16000000","16001000","17021000","17025000","17025001",
      "17025002","17025003","17025004","17025005","17032000","17035000","18003000","18006001","18006002","18006004","18006006",
      "18006007","18006008","18006009","18010000","18012000","18012002","18020005","18021000","18021001","18021002","18023000",
      "18024000","18024001","18024002","18024005","19000000","19001000","19002000","19003000","19004000","19005000","19005001",
      "19005002","19005003","19005004","19005005","19005006","19005007","19006000","19007000","19008000","19009000","19010000",
      "19011000","19012000","19012001","19012002","19012003","19012004","19012005","19012006","19012007","19012008","19013000",
      "19013001","19013002","19013003","19014000","19015000","19016000","19017000","19018000","19019000","19020000","19021000",
      "19022000","19023000","19024000","19025000","19025001","19025002","19025003","19025004","19026000","19027000","19028000",
      "19029000","19030000","19031000","19032000","19033000","19034000","19035000","19036000","19037000","19038000","19039000",
      "19040000","19040001","19040002","19040003","19040004","19040005","19040006","19040007","19040008","19041000","19042000",
      "19043000","19044000","19045000","19046000","19047000","19048000","19049000","19050000","19051000","19052000","19053000",
      "19054000","21000000","21001000","21002000","21003000","21004000","21005000","21006000","21007000","21007001","21007002",
      "21008000","21009000","21009001","21010000","21010001","21010002","21010003","21010004","21010005","21010006","21010007",
      "21011000","21012000","21012001","21012002","22016000"
    ].include?(category_id)
  end

  def likely_category?(category_id)
    [
      "10000000","12003000","12008000","12008001","12008002","12008003","12008004","12008005","12008006","12008007","12008008",
      "12008009","12008010","12008011","12015000","12015001","12015002","12015003","12017000","12019000","12019001","14001000",
      "14001001","14001004","14001006","14001007","14001013","14001014","14001016","14001017","17009000","17011000","17012000",
      "17015000","17016000","17017000","17030000","17031000","17033000","17034000","17041000","17045000","18001000","18001002",
      "18001006","18001007","18001008","18008000","18011000","18020000","18020003","18020006","18020007","18020008","18024004",
      "18045000","18050004","18060000","18071000","22006001","22013000"
    ].include?(category_id)
  end

  def very_likely_category?(category_id)
    [
      "12002000","12002001","12002002","12005000","17001004","17001005","17018000","17028000","17042000","17047000","18000000",
      "18009000","18014000","18020004","18030000","18031000","18061000","18063000","18068000","18068001","18068002","18068003",
      "18068004","18068005","18070000"
    ].include?(category_id)
  end

end