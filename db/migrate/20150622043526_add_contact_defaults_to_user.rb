class AddContactDefaultsToUser < ActiveRecord::Migration
  def change
  	change_column_default :users, :email_summary, true
  	change_column_default :users, :email_alert, true
  end
end
