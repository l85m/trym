class StopOrdersController < ApplicationController
  before_action :set_stop_order, only: [:show, :edit, :update, :destroy]

  respond_to :html, :js

  def index
    @stop_orders = StopOrder.all
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
    @stop_order = StopOrder.new charge: @charge, status: 'requested', merchant: @merchant    
  end

  def edit
  end

  def create
    @stop_order = stop_order.new(stop_order_params)
    @stop_order.save
    respond_with(@stop_order)
  end

  def update
    @stop_order.update(stop_order_params)
    respond_with(@stop_order)
  end

  def destroy
    @stop_order.destroy
    respond_with(@stop_order)
  end

  private
    def set_stop_order
      @stop_order = StopOrder.find(params[:id])
    end

    def stop_order_params
      params.require(:stop_order).permit(:name, :type)
    end
end
