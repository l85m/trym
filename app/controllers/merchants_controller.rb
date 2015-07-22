class MerchantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    render json: Merchant.selection_search(params[:q], params[:trym_category_id], params[:allow_new])
  end

  def new
    @merchant_alias = MerchantAlias.find params[:merchant_alias_id]
    @merchant = Merchant.new
  end

  def create
    @merchant = Merchant.create merchant_params
    @merchant.merchant_aliases << MerchantAlias.find(params[:merchant][:merchant_alias_id])
  end

  private

  def merchant_params
    params.require(:merchant).permit( :name, :validated, :trym_category_id, :recurring_score )
  end
end