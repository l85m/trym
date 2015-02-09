class FinancialInstitutionsController < ApplicationController
  before_action :authenticate_user!
	respond_to :json

	def index
		@financial_institutions = FinancialInstitution.find_by_fuzzy_name(params[:q], limit: 5).select{ |f| f.connect }
	end
	
end