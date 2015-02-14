class ChargeBuilder

	def initialize(transaction_request)
		@transaction_request = transaction_request
		@user_id = transaction_request.linked_account.user.id
		create_charges
	end

	def create_charges
		charges = PlaidTransactionParser.new(@transaction_request.data).charge_list
		if charges.present?
			charges.each do |charge|
				unless charge_already_exists?(charge) || is_debit?(charge)
					#Do not add the charge if there's already a charge with the same description on that linked account
					Charge.create(sanitize_charge_params(charge))
				end
			end
		end
	end

	def charge_already_exists?(charge)
		Charge.where( description: charge[:name], linked_account_id: @transaction_request.linked_account.id ).present? || 
		Charge.where( merchant_id: charge[:merchant_id], linked_account_id: @transaction_request.linked_account.id ).present?
	end

	def is_debit?(charge)
		charge[:amount] < 0
	end

	def sanitize_charge_params(charge)
		{
			amount: charge[:amount],
			billing_day: charge[:billing_day],
			category_id: charge[:category_id],
			recurring_score: charge[:recurring_score],
			description: charge[:name],
			merchant_id: charge[:merchant_id],
			renewal_period_in_weeks: charge[:renewal_period_in_weeks],
			user_id: @user_id,
			transaction_request_id: @transaction_request.id,
			new_transaction: charge[:new_transaction],
			linked_account_id: @transaction_request.linked_account.id
		}
	end
end