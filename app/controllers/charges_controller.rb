class ChargesController < ApplicationController
  before_action :set_charge, only: [:edit, :update, :destroy]
  before_action :create_merchant_if_new, only: [:create, :create_then_manage, :update]
  before_action :convert_amount_to_number, only: [:create, :update]
  before_action :authenticate_user!

  respond_to :html, :js

  def index
    session.delete(:charge_wizard_categories)
    
    @charges = current_user.charges.recurring.page(params[:page]).per(15)
    @charges_outlook_chart_data = ChargesOutlookChartData.new(current_user, @charges)
    @linked_accounts = current_user.linked_accounts.linked
    #@charges = @charges.sort_by{ |c| [c.next_billing_date ? 0 : 1, c.next_billing_date] }.reverse
    @stop_orders = current_user.stop_orders.active_or_complete.order(created_at: :desc)
    
    respond_with(@charges)
  end

  def outlook    
    @charges_outlook_chart_data = ChargesOutlookChartData.new(current_user, current_user.charges.recurring.with_merchant)
  end

  def search
    @category = TrymCategory.find(params[:trym_category_id]) if params[:trym_category_id].present?
    @query = params[:q]

    if @category.present? && @query.blank?
      @charges = @category.charges.where(user: current_user).with_merchant.sort_by_recurring_score.page(params[:page]).per(15)
  
    elsif @query.present?
  
      merchant_ids = Merchant.where("name ILIKE ?", "%#{@query}%").pluck(:id)
      merchant_name_query = merchant_ids.present? ? " OR merchant_id IN (#{merchant_ids.join(',')})" : ''
      
      if params[:linked_account_id].present?
        @linked_account = LinkedAccount.find(params[:linked_account_id])
        @charges = @linked_account.charges.where("plaid_name ILIKE ? OR description ILIKE ?#{merchant_name_query}", "%#{@query}%", "%#{@query}%").
                                          sort_by_recurring_score.
                                          page(params[:page]).per(15)
      else
        @charges = current_user.charges.with_merchant.
                                      where("plaid_name ILIKE ? OR description ILIKE ?#{merchant_name_query}", "%#{@query}%", "%#{@query}%").
                                      sort_by_recurring_score.
                                      page(params[:page]).per(15)
      end

    else
  
      if params[:linked_account_id].present?
        @charges = @linked_account.charges.with_merchant.sort_by_recurring_score.page(params[:page]).per(15)
   
      else
        @charges = current_user.charges.with_merchant.sort_by_recurring_score.page(params[:page]).per(15)
      end
    end
  end

  def create_then_manage
    @charge = current_user.charges.find_or_create_by(charge_params)
    unless @charge.new_record?
      @stop_order = StopOrder.find_or_create_by( charge_id: @charge.id, status: "started" )
      redirect_to stop_order_manage_account_path( :manage_account, stop_order_id: @stop_order.id)
    end
  end

  def new
    @title = "new charge"
    @trym_category_id = TrymCategory.find(params[:trym_category_id]).id if params[:trym_category_id].present?

    @charge = current_user.charges.build( renewal_period_in_weeks: 4, trym_category_id: params[:trym_category_id])
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
    @charge.update(charge_params)
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
      unless (@charge.present? && @charge.amount.present? && params[:charge][:amount] == ( @charge.amount * 100 ))
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