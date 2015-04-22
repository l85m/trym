class ChangeDefaultValueOnStopOrderStatus < ActiveRecord::Migration
  def change
  	change_column_default :stop_orders, :status, 'started'
  end
end
