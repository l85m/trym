class AddStatusToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :status, :text, null: false, default: "started"
  end
end
