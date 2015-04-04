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
		steps = ["started", "requested", "working", "finished"]
		i = steps.index(stop_order.status)
		
		steps.map(&:titlecase).zip( Array.new(4){ |x| x < i ? 'complete' : (x == i ? 'active' : 'disabled') } ).to_h
	end

end
