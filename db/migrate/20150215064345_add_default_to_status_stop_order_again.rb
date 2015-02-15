class AddDefaultToStatusStopOrderAgain < ActiveRecord::Migration
  def change
  	change_column_default :stop_orders, :status, "requested"
  end
end
