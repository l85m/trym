class PlaidMerchantAliasCreator

  def initialize(transactions)
  	@transactions = transactions
  	
  	if @transactions.present?
  		@financial_institution_id = @transactions.first.financial_institution.id
  	end

  	if @financial_institution_id
  		create_new_aliases
  	end
  end

  def create_new_aliases
  	new_merchant_aliases.each do |t|
  		begin
  			MerchantAlias.create( alias: t.name, financial_institution_id: @financial_institution_id, transaction_id: t.id )
  		rescue => e
  			Rails.logger.warn "[PlaidMerchantAliasCreator][#{Time.now}] Failed to save MerchantAlias: #{e}"
  		end
  	end
  end

  def new_merchant_aliases
  	candidate_aliases = @transactions.select('distinct on (name) *')
  	existing_aliases = MerchantAlias.where( alias: candidate_aliases.map(&:name), financial_institution_id: @financial_institution_id ).pluck(:alias)
  	candidate_aliases.reject { |transactions| existing_aliases.include? transactions.name }
  end

end