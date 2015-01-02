class AddCallWindowToStopOrders < ActiveRecord::Migration
  def change
    add_column :stop_orders, :call_window, :datetime
  end
end
