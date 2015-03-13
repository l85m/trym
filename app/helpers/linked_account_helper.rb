module LinkedAccountHelper

  def charge_group_button(grouping, grouped_charges, grouping_present)
    return {class: "btn btn-primary-o btn-block"} unless grouped_charges.present?
    if grouping_present.present?
      {
        class: "btn btn-primary-o btn-block collapse-expand-button in active",
        href: "#collapse-#{grouping.downcase.gsub(" ","-")}",
        aria_expanded:"true", 
        aria_controls:"collapse-#{grouping.downcase.gsub(" ","-")}", 
        data: {toggle:"collapse"},
        style: "margin-bottom: 10px;"
      } 
    else
      if grouped_charges.first.recurring
        {
          class: "btn btn-primary-o btn-block collapse-expand-button",
          href: "#collapse-#{grouping.downcase.gsub(" ","-")}",
          aria_expanded:"false",
          aria_controls:"collapse-#{grouping.downcase.gsub(" ","-")}", 
          data: {toggle:"collapse"},
          style: "margin-bottom: 10px;"
        }      
      elsif grouped_charges.first.recurring_score > 1
        {
          class: "btn btn-primary-o btn-block collapse-expand-button in active",
          href: "#collapse-#{grouping.downcase.gsub(" ","-")}",
          aria_expanded:"true",
          aria_controls:"collapse-#{grouping.downcase.gsub(" ","-")}", 
          data: {toggle:"collapse"},
          style: "margin-bottom: 10px;"
        }
      else
        {
          class: "btn btn-primary-o btn-block",
          href: linked_account_path(id: grouped_charges.first.linked_account_id, grouping: grouping),
          onclick: "buttonLoader($(this));",
          style: "margin-bottom: 10px;",
          data: {remote: true}
        }
      end
    end
  end

  def cols_for_grouped_charges(grouped_charges, charges, charge)
    base = "col-lg-4 col-md-6 col-xs-12"
    if charges.index(charge) == 0
      case charges.count
      when 1
        base += " col-lg-offset-4"
        base += " col-md-offset-3" if (grouped_charges.count < 3 && charges.count < 3)
      when 2
        base += " col-lg-offset-2"
        base += " col-md-offset-3" if (grouped_charges.count < 3 && charges.count < 3)
      end
    end
    base
  end

end