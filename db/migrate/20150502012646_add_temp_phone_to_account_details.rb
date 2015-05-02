class AddTempPhoneToAccountDetails < ActiveRecord::Migration
  def change
    add_column :account_details, :temp_phone, :text
  end
end
