class AddDefaultContactPreferenceToStopOrders < ActiveRecord::Migration
  def change
  	change_column_default :stop_orders, :contact_preference, "call"
  end
end
