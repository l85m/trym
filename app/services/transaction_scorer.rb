class TransactionScorer

  ## charge = a transaction object from plaid
  ## @dates = past transactions from this merchant/source (ie all transactions 
  ##          from the apple store) sorted in ascending order (newer dates last)
  ## @merchant_id = 
  def initialize(charge)
    @charge = charge
    @dates = charge[:date].sort
    @name = charge[:name].downcase
    @amounts = charge[:amount]
    @merchant_id = charge[:merchant_id]
    @category_id = charge[:category_id]
    calculate_recurring_score
  end

  ## Returns integer score representing how likely a charge is to recur.  Higher
  ## score is better.
  def calculate_recurring_score
    score = 0

    if @dates.size > 1

      if ( uniform_distance_between_dates > 6 || dates_are_yearly? ) && interval_likely_recurring?
        score += 4
        score += 2 if amounts_are_similar?
      else
        score += -1 if not (dates_are_weekly? || dates_are_monthly?)
      end

    end
      
    
    score += 2 if likely_category?
    score += 3 if very_likely_category?
    
    score += -1 if unlikely_category?
    score += -2 if very_unlikely_category?

    score += 3 if likely_description?
    score -= 1 if unlikely_description?
    
    if @merchant_id.present?
      score += Merchant.find(@merchant_id).recurring_score
    end

    score -= 10 if last_charge_over_one_year_ago?

    score
  end

  def last_charge_over_one_year_ago?
    @dates.max < 1.year.ago
  end

  def interval_likely_recurring?
    distance = uniform_distance_between_dates
    distance == 7               ||  #weekly
    distance == 14              ||  #bi-weekly
    distance.between?(28, 32)   ||  #monthly
    distance.between?(84, 93)   ||  #quarterly
    distance.between?(170, 190) ||  #bi-annually
    distance.between?(350, 370)     #annually
  end

  def dates_are_weekly?
    weeks = @dates.collect{ |d| d.strftime("%U").to_i }
    (weeks.sort[-1] - weeks.sort[0]) == (weeks.size - 1)
  end

  def dates_are_monthly?
    months = @dates.collect{ |d| d.strftime("%-m").to_i }
    (months.sort[-1] - months.sort[0]) == (months.size - 1)
  end

  def dates_are_yearly?
    years = @dates.collect{ |d| d.strftime("%-y").to_i }
    (years.sort[-1] - years.sort[0]) == (years.size - 1)
  end

  def distance_between_last_two_dates
    return 0 unless @dates.size > 1
    @dates[-2..-1].reverse.inject(:-).to_i
  end

  def uniform_distance_between_dates
    distances = @dates[-(@dates.size > 4 ? 4 : @dates.size)..-1].each_cons(2).collect{ |a,b| (b - a).to_i }.sort
    if @dates.size > 2
      variance = (distances.max - distances.min) / distances.max.to_f
      if variance < 0.1
        return distances[distances.size/2]  
      else
        return -1
      end
    else
      (dates_are_yearly? && distances.first.between?(350, 370)) ? distances.first : -1
    end
  end

  def amounts_are_similar?
    (@amounts.each_cons(2).map{ |a,b| (b-a).abs }.max / @amounts.min.to_f) < 0.1
  end

  def unlikely_description?
    [
      "taxi", "yellow cab", "hotel", "bar", "restaurant", "lodging", "refund", "reward", "transfer", "foods", "pizza", "outlet",
      "airport", "toll", "beverage", "resort", "airlines", "fuel", "gas", "coffee", "market", "drive-thru", "limo", "cafe", "air lines",
      "drugs", "emergency", "halloween", "christmas", "tire", "toys", "breakfast", "lunch", "dinner", "donuts", "ice cream", "tacos",
      "pub", "juice", "thai", "japanese", "mexican", "italian", "chinese", "kitchen", "hamburger", "grill", "sushi", "grocery"
    ].select{ |d| @name.include?(d) }.present?
  end

  def likely_description?
    [
      "membership", "recurring", "monthly", "annual", "periodic", "insurance"
    ].select{ |d| @name.include?(d) }.present?
  end

  def very_unlikely_category?
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
    ].include?(@category_id)
  end

  def unlikely_category?
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
    ].include?(@category_id)
  end

  def likely_category?
    [
      "10000000","12003000","12008000","12008001","12008002","12008003","12008004","12008005","12008006","12008007","12008008",
      "12008009","12008010","12008011","12015000","12015001","12015002","12015003","12017000","12019000","12019001","14001000",
      "14001001","14001004","14001006","14001007","14001013","14001014","14001016","14001017","17009000","17011000","17012000",
      "17015000","17016000","17017000","17030000","17031000","17033000","17034000","17041000","17045000","18001000","18001002",
      "18001006","18001007","18001008","18008000","18011000","18020000","18020003","18020006","18020007","18020008","18024004",
      "18045000","18050004","18060000","18071000","22006001","22013000"
    ].include?(@category_id)
  end

  def very_likely_category?
    [
      "12002000","12002001","12002002","12005000","17001004","17001005","17018000","17028000","17042000","17047000","18000000",
      "18009000","18014000","18020004","18030000","18031000","18061000","18063000","18068000","18068001","18068002","18068003",
      "18068004","18068005","18070000"
    ].include?(@category_id)
  end

end