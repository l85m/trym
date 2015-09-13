module StaticPagesHelper
	def greeting_text( user )
		categories = user.charges.collect{ |c| c.smart_trym_category }.uniq.compact

		if user.charges_due_in_next_seven_days
			msg = "i found <span class='brand-color'>#{pluralize user.charges_due_in_next_seven_days.count, 'charge'}</span> due in the next 7 days.<br>would you like me to cancel or change any charges?"
			subtext = content_tag(:p, msg.html_safe, class: "lead trym-subtext")
			btn = link_to "cancel or modify a recurring charge", charges_path, class: "btn btn-primary btn-wide"
		
		elsif user.linked_accounts.blank?
			msg = "if you link me to your credit card accounts i can find recurring charges automatically, even those you add later.<br>would you like to link any accounts?"
			subtext = content_tag(:p, msg.html_safe, class: "lead trym-subtext")
			btn = link_to "link an account to trym", linked_accounts_path, class: "btn btn-primary btn-wide"
				
		elsif categories.present? && categories.count < TrymCategory.count
			msg = "i am not tracking recurring charges for you in <span class='brand-color'>#{pluralize(TrymCategory.count - categories.count, 'major category', 'major categories')}</span>.<br>would you like to review in case you're missing some charges?"
			subtext = content_tag(:p, msg.html_safe, class: "lead trym-subtext")
			btn = link_to "link an account to trym", new_charge_path, class: "btn btn-primary btn-wide"

		elsif false 
			#TODO: we found some new charges we think are recurring
		
		elsif false
			#TODO: 
		end
		
		if defined? subtext
			content_tag(:div, subtext, class: "text-center") + content_tag(:div, btn, class: "text-center") 
		else
			nil
		end
	end

	def demo_charges
		[
			[Merchant.find_by_name("Comcast"), {amount: 12131, period: 4, times: 14}],
			[Merchant.find_by_name("FreeCreditReport.com"), {amount: 7995, period: 52, times: 3}],
			[Merchant.find_by_name("Gold's Gym"), {amount: 6231, period: 4, times: 22}]
		].collect do |m, data|
			day = Date.today + (30 * rand).to_i
			history = data[:times].times.collect do |i| 
				[
					(day - (i * 7 * data[:period])).strftime("%b %e, %Y"), 
					(data[:amount] + data[:amount] * ( rand() > 0.05 ? 0 : rand(-0.5..2) ))/100
				]
			end.reverse.to_h
			[Charge.new( 
				merchant: m,
				amount: data[:amount], 
				billing_day: day, 
				renewal_period_in_weeks: data[:period],
				recurring: true,
				history: history
			), history]
		end
	end
end
