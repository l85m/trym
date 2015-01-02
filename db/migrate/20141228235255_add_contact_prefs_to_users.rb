class AddContactPrefsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_summary, :boolean, null: false, default: false
    add_column :users, :email_alert, :boolean, null: false, default: false
    add_column :users, :text_summary, :boolean, null: false, default: false
    add_column :users, :text_alert, :boolean, null: false, default: false
  end
end
