class ChargesController < ApplicationController
  before_action :set_charge, only: [:edit, :update, :destroy]
  before_action :create_merchant_if_new, only: [:create, :update]
  before_action :convert_amount_to_number, only: [:create, :update]
  before_action :authenticate_user!

  respond_to :html, :js

  def index
    @title = "charges"
    @charges = current_user.charges.recurring.with_merchant
    @charges_outlook_chart_data = ChargesOutlookChartData.new(current_user, @charges)
    @linked_accounts = current_user.linked_accounts
    respond_with(@charges)
  end

  def new
    @title = "new charge"
    @charge = current_user.charges.build
  end

  def edit
    @attribute = params[:attribute]
  end

  def create
    @charge = current_user.charges.create(charge_params)
    respond_to do |format|
      format.js
      format.html {redirect_to charges_path}
    end
  end

  def update
    @update_from_account_scan = ( charge_params["recurring"].present? || params["charge"]["account_scan"].present? )
    @charge.update(charge_params)
    respond_with(@charge)
  end

  def destroy
    @charge.destroy
  end

  private

    def set_charge
      @charge = Charge.find(params[:id])
    end

    def charge_params
      params.require(:charge).permit(:merchant_id, :description, :amount, :recurring, :billing_day, :renewal_period_in_weeks)
    end

    def convert_amount_to_number
      unless (@charge.present? && params[:charge][:amount] == ( @charge.amount * 100 )) || params[:charge][:merchant_id].nil?
        if params[:charge][:amount].is_a?(String)
          params[:charge][:amount] = (params[:charge][:amount].gsub("$","").gsub(" ","").to_f * 100).to_i
        end
      end
    end

    def create_merchant_if_new
      unless (@charge.present? && params[:charge][:merchant_id] == @charge.merchant_id) || params[:charge][:merchant_id].nil?
        if (true if Integer(params[:charge][:merchant_id]) rescue false)
          params[:charge][:merchant_id] = Merchant.find(params[:charge][:merchant_id]).id
        else
          params[:charge][:merchant_id] = Merchant.create(name: params[:charge][:merchant_id]).id
        end
      end
    end

end