class SummaryWorker
	include Sidekiq::Worker
	
	def perform
		User.summarizable.joins(:charges).group('users.id').find_each do |user|
			charges = user.charges.charged_in_month
			if charges.present?
				send_email_summary(user,charges) if user.email_summary
				send_text_summary(user, charges) if user.text_summary
			end
		end
	end

	private

	def send_email_summary(user,charges)
		ChargeMailer.monthly_summary(user,charges).deliver 
	end

	def send_text_summary(user,charges)
		Twilio::REST::Client.new.account.messages.create(
			from: Rails.application.secrets.twilio_from_number,
			to: user.account_detail.phone,
			body: text_body_for(charges)
		)
	end

	def text_body_for(charges)
		body = "Hi from Trym! Here's the services which charged you in #{1.month.ago.strftime('%B')}: "
		body += charges.collect{ |c| "\n#{c.descriptor}" + (c.amount_in_currency.present? ? ": $#{c.amount_in_currency.round}," : '') }.join
		body += "\nGoto www.trym.io if you'd like us to cancel or change any of your services."
	end

end