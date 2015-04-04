module ChargesHelper

  def recurring_factors_for(charge)
    return "<a data-toggle='tooltip' data-title='Trym thinks this charge is recurring because you created it'><i class='fa recurring-factor fa-user recurring-factor-good'></i></a>".html_safe unless charge.transaction_request.present?
    interval_class = "fa-calendar"
    amount_class = "fa-usd"
    category_class = "fa-tags"
    merchant_class = "fa-building"

    factors = TransactionScorer.new(charge).reason_for_score.collect do |r, v|
      {
        dates_are_perfectly_recurring: [interval_class, v],
        amounts_are_similar: [amount_class, v],
        amounts_are_not_similar: [amount_class, v],
        interval_likely_recurring: [interval_class, v],
        interval_looks_recurring_with_limited_data: [interval_class, v],
        interval_not_likely_recurring: [interval_class, v],
        last_charge_too_long_ago: [interval_class, v],
        one_transaction: [interval_class, v],
        one_transaction_more_than_one_month_ago: [interval_class, v],
        one_transaction_more_than_one_year_ago: [interval_class, v],
        likely_category: [category_class, v],
        very_likely_category: [category_class, v],
        unlikely_category: [category_class, v],
        very_unlikely_category: [category_class, v],
        likely_description: [category_class, v],
        unlikely_description: [category_class, v],
        merchant_recurring_score: [merchant_class, v]
      }[r]
    end.sort_by{ |_,v| v }.inject({}){ |h,(k,v)| h[k].present? ? h[k] += v : h[k] = v ; h}.reject{ |_,v| v.between?(-1,1) }.
        collect do |f, v| 
          recurring_explanation = "Trym thinks this charge #{ v > 0 ? 'is' : 'is not' } recurring because " + {
            "fa-calendar" => "of when you were charged",
            "fa-usd" => "some past charges were #{v < 0 ? 'not' : nil} for similar amounts",
            "fa-tags" => "of the merchant category provided by your bank",
            "fa-building" => "it recognized the merchant name"
          }[f]
          "<a data-toggle='tooltip' data-title='#{recurring_explanation}'>" + 
          "<i class='fa recurring-factor #{f} recurring-factor-#{v > 0 ? "good" : "bad"}'></i></a>"
        end.
        join(" ").html_safe

    factors.present? ? factors : "<small>n/a</small>".html_safe
  end

  def stop_order_charge_ids
    current_user.charges.with_active_stop_orders.pluck(:id)
  end

  def merchant_name_example_helper(trym_category_id)
    if trym_category_id.present?
      merchant_names = TrymCategory.find(trym_category_id).merchants.limit(2).pluck(:name)
      merchant_names.present? ? merchant_names.join(', ') + ', ect.' : "search for company"
    else
      "Comcast, Geico, Gold's Gym, ect."
    end
  end

  def time_to_next_bill(next_billing_date)
    if next_billing_date == Date.today
      "due today"
    else
      "next charge in " +  (distance_of_time_in_words next_billing_date.to_time - Time.now.beginning_of_day)
    end
  end

  def billing_interval_in_words(renewal_period_in_weeks)
    interval = Charge.renewal_period_in_words[renewal_period_in_weeks]
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
    when "billing_day" then charge.next_billing_date.present? ? charge.next_billing_date : charge.billing_day
    else 
      charge.send(attribute)
    end
  end

  def formatted_history(history)
    if history.present?
      "<div class='charge-history-container'>" +
      "<div class='strong charge-history-left'>2 Yr Total:</div><div class='strong charge-history-right'>#{number_to_currency history.values.inject(0.0){ |s,v| s+= v.to_f }}</div>" +
      history.to_a.reverse.collect{ |d,v| "<div><div class='charge-history-left'>#{d}:</div><div class='charge-history-right'>#{number_to_currency v.to_f}</div>" }.join("</div>")+
      "</div>"

    else
      nil
    end
  end

end
