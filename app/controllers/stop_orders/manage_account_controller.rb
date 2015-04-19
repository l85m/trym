class StopOrders::ManageAccountController < ApplicationController
  layout 'manage_account'

  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :set_stop_order

  before_action :set_steps
  before_action :setup_wizard
  
  def show
    if step == :name_and_phone
      @account_detail = current_user.account_detail
      @account_detail ||= AccountDetail.new(user: current_user)
    end
    render_wizard
  end

  def update
    @stop_order.update(stop_order_params)
    render_wizard @stop_order
  end
  
  private

  def set_stop_order
    @stop_order = current_user.stop_orders.find(params[:stop_order_id])
    @charge = @stop_order.charge
  end

  def set_steps
    if params["id"] == "name_and_phone" && current_user.phone_verified?
      params["id"] = "manage_account"
    end
    option = stop_order_params.fetch(:option) rescue @stop_order.option
    self.steps = [:manage_account] + (current_user.phone_verified? ? [] : [:name_and_phone]) + [:accept_terms] + all_steps.fetch(option) + [:account_details]
  end

  def stop_order_params
    params.require(:stop_order).permit(:option, :accept_equipment_return, :fee_limit, :status, cancelation_data: @stop_order.cancelation_fields + [:comments])
  end

  def all_steps
    {
      "cancel_all" => [ :termination_details ],
      "downgrade"  => [ :termination_details ],
      "upgrade"    => [ ],
      "find_deals" => [ ],
      nil => []
    }
  end

  def finish_wizard_path
    charges_path
  end
end