class AddAccountDataToAccountDetails < ActiveRecord::Migration
  def change
  	add_column :account_details, :account_data, :hstore, null: false, default: {}
  end
end
