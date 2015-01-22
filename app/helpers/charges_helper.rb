module ChargesHelper

  def time_to_next_bill(next_billing_date)
    if next_billing_date == Date.today
      "due today"
    else
      "next charge in " + (next_billing_date.present? ? (distance_of_time_in_words next_billing_date.to_time - Time.now.beginning_of_day) : "???")
    end
  end

  def billing_interval_in_words(renewal_period_in_weeks)
    interval = Charge.renewal_period_in_words.merge({0 => "Monthly?", nil => "Monthly?"})[renewal_period_in_weeks]
    interval.present? ? interval.split(" - ").first : "#{renewal_period_in_weeks}-Weekly"
  end

  def charge_attribute_edit_link(charge, attribute, &block)
    link_to edit_charge_path(id: charge.id, attribute: attribute), class: "charge-mini-edit-link", remote: true, data:{placement: tooltip_placement_for(attribute)}, &block
  end

  def tooltip_placement_for(attribute)
    ["amount", "renewal_period_in_weeks"].include?(attribute) ? "left" : "right"
  end

  def attribute_input_value(charge, attribute)
    case attribute
    when "merchant" then nil
    when "amount" then number_to_currency(charge.amount / 100.0, precision: 2)
    when "billing_day" then charge.next_billing_date
    else 
      charge.send(attribute)
    end
  end


end
