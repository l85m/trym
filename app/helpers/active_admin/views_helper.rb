module ActiveAdmin::ViewsHelper
	def order_age_class(order)
		return "" unless order.cancelable?
		
		created = order.created_at
		if order.status == "requested"
			if created < 2.days.ago.beginning_of_day
				return "danger"
			elsif created < 1.day.ago.beginning_of_day
				return "warning"
			else
				return ""
			end
		else
			if created < 3.days.ago.beginning_of_day
				return "danger"
			elsif created < 2.days.ago.beginning_of_day
				return "warning"
			else
				return ""
			end
		end
	end  
end