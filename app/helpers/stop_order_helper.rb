module StopOrderHelper

	def manage_account_first_person_action_statement(stop_order)
		case stop_order.option
		when "cancel_all" then "Cancel My Account"
		when "upgrade", "downgrade" then "Change My Account"
		when "find_deals" then "Find Me Deals"
		else 
			nil
		end
	end

	def manage_account_second_person_action_statement(stop_order)
		manage_account_first_person_action_statement(stop_order).gsub("My", "Your").gsub("Me", "You")
	end

	def manage_account_progress(stop_order)
		steps = ["requested", "working", "finished"]
		i = steps.index(%w(succeeded failed canceled).include?(stop_order.status) ? "finished" : stop_order.status)
		
		steps.map(&:titlecase).zip( Array.new(4){ |x| x < i ? 'complete' : (x == i ? 'active' : 'disabled') } ).to_h
	end

	def split_address(stop_order, type)
		if stop_order.cancelation_data.present?
			addr = stop_order.cancelation_data[:address]
		end

		if addr.nil? && current_user.account_detail.present? && current_user.account_detail.account_data.present?
			addr = current_user.account_detail.account_data[:address].presence || current_user.account_detail.account_data["address"]
		end
		
		return nil unless addr.present?
		zip_regex = /^\d{5}(?:[-\s]\d{4})?$/

		zip = addr.split(" ").last
		zip = "" unless zip_regex.match(zip).to_s == zip
		
		if type == "street"
			return addr.gsub(zip,'')
		else
			return zip
		end
	end

end
