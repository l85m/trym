class MerchantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    render json: Merchant.selection_search(params[:q], params[:trym_category_id])
  end
  
end