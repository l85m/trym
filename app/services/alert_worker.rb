class AlertWorker
	include Sidekiq::Worker
	
	def perform
		User.alertable.joins(:charges).group('users.id').find_each do |user|
			charges = user.charges.due_in_three_days
			if charges.present?
				send_email_alerts(user,charges) if user.email_alert
				send_text_alerts(user, charges) if user.text_alert
			end
		end
	end

	private

	def send_email_alerts(user,charges)
		ChargeMailer.three_days_before_charge(user,charges).deliver 
	end

	def send_text_alerts(user,charges)
		Twilio::REST::Client.new.account.messages.create(
			from: Rails.application.secrets.twilio_from_number,
			to: user.account_detail.phone,
			body: text_body_for(charges)
		)
	end

	def text_body_for(charges)
		body = "Hi from Trym! In three days "
		if charges.size > 1
			body += "the following services are scheduled to charge you: "
			body += charges.collect{ |c| "\n#{c.descriptor}" + (c.amount_in_currency.present? ? ": $#{c.amount_in_currency.round}," : '') }.join
			pronoun = "these services"
		else
			c = charges.first
			body += "#{c.descriptor} is scheduled to charge you $#{c.amount_in_currency.round}."
			pronoun = "this service"
		end
		body += "\nGoto www.trym.io to change #{pronoun} before the next billing cycle starts."
	end

end