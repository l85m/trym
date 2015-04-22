class AddContactPreferenceToStopOrders < ActiveRecord::Migration
  def change
    add_column :stop_orders, :contact_preference, :text
  end
end
