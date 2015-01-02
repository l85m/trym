class AddConfirmationCodeToAccountDetails < ActiveRecord::Migration
  def change
  	remove_column :account_details, :phone_verified
  	add_column :account_details, :phone_verified, :datetime
  	add_column :account_details, :confirmation_code, :text  	
  end
end
