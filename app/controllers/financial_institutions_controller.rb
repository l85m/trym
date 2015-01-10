class FinancialInstitutionsController < ApplicationController
	respond_to :json

	def index
		@financial_institutions = FinancialInstitution.find_by_fuzzy_name(params[:q], limit: 5)
	end
	
end



