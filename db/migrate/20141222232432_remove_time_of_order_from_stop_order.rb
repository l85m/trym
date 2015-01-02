class RemoveTimeOfOrderFromStopOrder < ActiveRecord::Migration
  def change
  	remove_column :stop_orders, :time_of_order
  end
end
