class AddCancelationStuffToMerchantsAndStopOrders < ActiveRecord::Migration
  def change
  	add_column :merchants, :cancelation_fields, :text, array: true
  	add_column :stop_orders, :cancelation_data, :hstore
  end
end
