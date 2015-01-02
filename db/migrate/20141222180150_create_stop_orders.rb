class CreateStopOrders < ActiveRecord::Migration
  def change
    create_table :stop_orders do |t|
      t.references :charge, index: true
      t.references :merchant, index: true
      t.time :time_of_order
      t.text :status

      t.timestamps
    end
  end
end
