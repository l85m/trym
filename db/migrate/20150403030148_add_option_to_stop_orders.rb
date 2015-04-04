class AddOptionToStopOrders < ActiveRecord::Migration
  def change
    add_column :stop_orders, :option, :string
  end
end
