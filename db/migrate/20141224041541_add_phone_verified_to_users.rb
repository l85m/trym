class AddPhoneVerifiedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_verified, :boolean, default: false
  end
end
