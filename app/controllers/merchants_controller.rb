class MerchantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    @merchants = Merchant.selection_search(params[:q])
  end
  
end