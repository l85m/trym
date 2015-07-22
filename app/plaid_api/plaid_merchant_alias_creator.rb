class PlaidMerchantAliasCreator
  include Sidekiq::Worker

  def perform(transaction_request_data, linked_account_id)
  	@transaction_request_data = transaction_request_data
  	
  	if @transaction_request_data.present?
  		@financial_institution_id = LinkedAccount.find(linked_account_id).financial_institution_id
  	end

  	if @financial_institution_id
  		create_new_aliases
  	end
  end

  def create_new_aliases
  	new_merchant_aliases.each do |merchant_alias|
  		begin
  			MerchantAlias.create( alias: merchant_alias, financial_institution_id: @financial_institution_id )
  		rescue => e
  			Rails.logger.warn "[PlaidMerchantAliasCreator][#{Time.now}] Failed to save MerchantAlias: {e}"
  		end
  	end
  end

  def new_merchant_aliases
  	candidate_aliases = @transaction_request_data.collect{ |t| t["name"] }.uniq
  	existing_aliases = MerchantAlias.where(alias: candidate_aliases, financial_institution_id: @financial_institution_id ).pluck(:alias)
  	candidate_aliases - existing_aliases
  end

end	