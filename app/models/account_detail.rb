class AccountDetail < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :phone, :first_name, :last_name
  validates :confirmation_code, format: { with: /\A\d{4}\z/, message: "four numbers only" }, allow_blank: true

  phony_normalize :phone, :default_country_code => 'US'
	phony_normalize :temp_phone, :default_country_code => 'US'
	
	validates_plausible_phone :phone, :normalized_country_code => 'US'
	validates_plausible_phone :temp_phone, :normalized_country_code => 'US'

	after_update :force_reverification, if: Proc.new { |detail| detail.phone_changed? } #################TODO

	def formatted_phone
		if phone.present?
			"(#{phone.phony_formatted(spaces: '-', normalize: 'US')[2..4]}) #{phone.phony_formatted(spaces: '-', normalize: 'US')[6..-1]}"
		else
			nil
		end
	end

	def send_confirmation_code
		generate_confirmation_code
		Twilio::REST::Client.new.account.sms.messages.create(
			from: Rails.application.secrets.twilio_from_number,
			to: temp_phone,
			body: "Hi There! Here's your verification code from trym.io: #{confirmation_code}"
		)
	end

	def names_present?
		first_name.present? && last_name.present?
	end

	def confirmed?( confirm_param )
		if confirm_param == confirmation_code
			update(phone_verified: Time.now, confirmation_code: nil, phone: temp_phone, temp_phone: nil)
		else
			false
		end
	end

	private

	def generate_confirmation_code
		update( confirmation_code: rand(1000..9999) )
	end

	def force_reverification
		self.phone_verified = nil
		self.temp_phone = phone
		self.phone = nil
	end

end