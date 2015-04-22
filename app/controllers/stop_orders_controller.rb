class StopOrdersController < ApplicationController
  layout 'manage_account'

  before_action :authenticate_user!
  before_action :set_stop_order, only: [:show, :edit, :update, :destroy]

  respond_to :html, :js

  def index
    @stop_orders = current_user.stop_orders.all
    respond_with(@stop_orders)
  end

  def show
    respond_with(@stop_order)
  end

  def new
    @charge = Charge.find(params[:charge_id])
    
    unless current_user.phone_verified? || @charge.details_not_required?
      session[:referring_charge_id] = @charge.id
      redirect_to controller: 'account_details', action: 'new', charge_id: @charge.id
    end
    
    @merchant = @charge.merchant
    @stop_order = @charge.stop_orders.new
  end

  def edit
    redirect_to stop_order_manage_account_path(:manage_account, stop_order_id: @stop_order.id)
  end

  def create
    @charge = current_user.charges.find( params[:charge_id] )

    if @charge.has_stop_order_or_is_stopped?
      not_found
    else
      @stop_order = StopOrder.find_or_create_by( charge_id: @charge.id, status: "started" )
      redirect_to stop_order_manage_account_path(:manage_account, stop_order_id: @stop_order.id)
    end
  end

  def update
    @stop_order.update(stop_order_params)
    respond_with(@stop_order)
  end

  def destroy
    @stop_order.destroy
    redirect_to root_path
  end

  private
    def set_stop_order
      @stop_order = StopOrder.find(params[:id])
    end

    def cancelation_params
      merchant = Charge.find(params[:stop_order][:charge_id]).merchant
      if merchant.present? && merchant.cancelation_fields.present?
        Charge.find(params[:stop_order][:charge_id]).merchant.cancelation_fields.collect(&:to_sym)
      else
        nil
      end
    end

    def stop_order_params
      params.require(:stop_order).permit(:charge_id, cancelation_data: cancelation_params)
    end
end
