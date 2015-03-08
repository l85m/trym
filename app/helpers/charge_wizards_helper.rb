module ChargeWizardsHelper

	def wizard_charge_category_checkboxes(category, category_ids)
		charges = category.charges.where(user: current_user).from_link.recurring_or_likely_to_be_recurring.group_by{ |x| x[:transaction_request_id] }
		checked = category_ids.present? ? category_ids.include?(category.id) : charges.present?
		check_box_tag(charge_category_name(category), true, checked) + charge_category_checkbox_label(category, charges)
	end

	private

	def charge_category_name(category)
		"charge_wizard[category_ids][#{category.id}]"
	end

	def charge_category_checkbox_label(category, institutions_with_charges)
		content_tag(:b, category.name) + " " + 
		linked_charge_tags_for_category(institutions_with_charges) +
		tag("br") +
		content_tag(:span, category.description, class: "small-gray") 
	end

	def linked_charge_tags_for_category(institutions_with_charges)
		if institutions_with_charges.present?
			content_tag(:span) do 
				institutions_with_charges.collect do |institution_id, charges|
					institution = TransactionRequest.find(institution_id).linked_account.financial_institution
					content_tag(:span, "#{charges.count} found in #{institution.plaid_type}", class: "label label-primary")
				end.join(" ").html_safe
			end
		else
			""
		end
	end
end
