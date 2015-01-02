class AddVerificationToAccountDetails < ActiveRecord::Migration
  def change
  	remove_column :users, :phone
  	remove_column :users, :phone_verified
  	remove_column :users, :first_name
  	remove_column :users, :last_name
  	add_column :account_details, :phone_verified, :boolean, default: true
  end
end
