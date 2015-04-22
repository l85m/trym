class AddDefaultToCancelationDataOnStopOrders < ActiveRecord::Migration
  def change
  	change_column_default :stop_orders, :cancelation_data, {}
  end
end
