class PlaidLinkedAccountUpdater

	def new
		if Time.now.hour <= 19
			LinkedAccount.where("id % 10 = #{Time.now.hour % 10}").pluck(:id).each do |link|
				next unless link.plaid_access_token.present?
				PlaidTransactionGetter.perform_async(link)
				sleep 30
			end
		end
	end
end