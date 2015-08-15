class PlaidMerchantAliasCreator

  def initialize(transaction_request_data, linked_account_id)
  	@transaction_request_data = transaction_request_data
  	
  	if @transaction_request_data.present?
  		@financial_institution_id = LinkedAccount.find(linked_account_id).financial_institution_id
  	end

  	if @financial_institution_id
  		create_new_aliases
  	end
  end

  def create_new_aliases
  	new_merchant_aliases.each do |t|
  		begin
  			MerchantAlias.create( alias: t["name"], financial_institution_id: @financial_institution_id, transaction_meta_data: t )
  		rescue => e
  			Rails.logger.warn "[PlaidMerchantAliasCreator][#{Time.now}] Failed to save MerchantAlias: {e}"
  		end
  	end
  end

  def new_merchant_aliases
  	candidate_aliases = @transaction_request_data.uniq { |t| t["name"] }
  	existing_aliases = MerchantAlias.where( alias: candidate_aliases.map { |t| t["name"] }, financial_institution_id: @financial_institution_id ).pluck(:alias)
  	candidate_aliases.reject { |t| existing_aliases.include? t["name"] }
  end

end