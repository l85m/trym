class RemoveCallWindow < ActiveRecord::Migration
  def change
  	remove_column :stop_orders, :call_window
  	remove_reference :stop_orders, :call_window, index: true
  	drop_table :call_windows
  end
end
