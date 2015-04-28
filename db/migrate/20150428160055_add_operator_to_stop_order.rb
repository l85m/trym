class AddOperatorToStopOrder < ActiveRecord::Migration
  def change
  	add_column :stop_orders, :operator_id, :integer
  	add_index :stop_orders, :operator_id
  end
end
