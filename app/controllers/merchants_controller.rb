class MerchantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    @merchants = Merchant.validated.find_by_fuzzy_name(params[:q], limit: 5)
  end
  
end