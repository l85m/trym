module ChargesHelper

  def time_to_next_bill(charge)
    case charge.next_billing_date
    when Date.today
      "due today"
    when nil
      "unknown"
    else
      "next charge in " + (distance_of_time_in_words charge.next_billing_date.to_time - Time.now.beginning_of_day)
    end
  end

end
