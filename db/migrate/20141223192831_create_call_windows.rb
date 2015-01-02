class CreateCallWindows < ActiveRecord::Migration
  def change
    create_table :call_windows do |t|
      t.datetime :window_start, null: false
      t.integer :stop_orders_count, null: false, default: 0
      t.integer :operators, default: 1
    end
    add_reference :stop_orders, :call_window, index: true
  end
end
