class AccountDetail < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :phone, :first_name, :last_name
  validates :confirmation_code, format: { with: /\A\d{4}\z/, message: "four numbers only" }, allow_blank: true

  phony_normalize :phone, :default_country_code => 'US'
	validates_plausible_phone :phone, :normalized_country_code => 'US'

	def formatted_phone
		phone.phony_formatted(spaces: '-', normalize: 'US')[2..-1]
	end

	def send_confirmation_code
		generate_confirmation_code
		Twilio::REST::Client.new.account.sms.messages.create(
			from: Rails.application.secrets.twilio_from_number,
			to: phone,
			body: "Hi There! Here's your verification code: #{confirmation_code}"
		)
	end

	def names_present?
		first_name.present? && last_name.present?
	end

	def confirmed?( confirm_param )
		if confirm_param == confirmation_code
			update(phone_verified: Time.now, confirmation_code: nil)
		else
			false
		end
	end

	private

	def generate_confirmation_code
		update( confirmation_code: rand(1000..9999) )
	end

end