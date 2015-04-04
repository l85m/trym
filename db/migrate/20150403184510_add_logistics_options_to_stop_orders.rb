class AddLogisticsOptionsToStopOrders < ActiveRecord::Migration
  def change
    add_column :stop_orders, :accept_equipment_return, :boolean, default: false, null: false
    add_column :stop_orders, :fee_limit, :integer, default: 0, null: false
  end
end
