class MerchantsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_merchant, only: [:edit, :update]
  
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

  def edit
  end

  def update
    @merchant.update(merchant_params)
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:id])
  end

  def merchant_params
    params.require(:merchant).permit( :name, :validated, :trym_category_id, :recurring_score, :default_renewal_period, :definitely_recurring_if_in_renewal_period )
  end
end