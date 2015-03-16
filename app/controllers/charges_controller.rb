class ChargesController < ApplicationController
  before_action :set_charge, only: [:edit, :update, :destroy]
  before_action :create_merchant_if_new, only: [:create, :update]
  before_action :convert_amount_to_number, only: [:create, :update]
  before_action :authenticate_user!

  respond_to :html, :js

  def index
    @charges = current_user.charges.recurring.with_merchant
    @title = "charges"
    @charges_outlook_chart_data = ChargesOutlookChartData.new(current_user, @charges)
    @linked_accounts = current_user.linked_accounts
    @charges = @charges.sort_by{ |c| [c.next_billing_date ? 0 : 1, c.next_billing_date] }.reverse
    
    respond_with(@charges)
  end

  def list_all
    @view_all = true
    @category = TrymCategory.find(params[:trym_category_id]) if params[:trym_category_id].present?
    if params[:linked_account_id]
      @linked_account = current_user.linked_accounts.find(params[:linked_account_id])
      @charges = current_user.charges.where(linked_account: @linked_account).with_merchant.order(recurring_score: :desc).page(params[:page]).per(12)
    else
      @charges = current_user.charges.with_merchant.order(recurring_score: :desc).page(params[:page]).per(12)
    end
  end

  def search
    @category = TrymCategory.find(params[:trym_category_id]) if params[:trym_category_id].present?
    @query = params[:q]
    @charges = current_user.charges.not_recurring.with_merchant.
                            find_by_fuzzy_plaid_name(@query, limit: params[:limit].present? ? params[:limit].to_i : 4).
                            select{ |c| c.plaid_name.similar(@query) >= 0.7 }
  end

  def new
    @title = "new charge"
    @trym_category_id = params[:trym_category_id].to_i if params[:trym_category_id].present?
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
    @update_from_view_all = params["view_all"] == 'true'
    @charge.update!(charge_params)
    respond_with(@charge)
  end

  def destroy
    @charge.destroy
  end

  private

    def set_charge
      @charge = current_user.charges.find(params[:id])
    end

    def charge_params
      params.require(:charge).permit(:merchant_id, :description, :amount, :recurring, :billing_day, :renewal_period_in_weeks, :trym_category_id)
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