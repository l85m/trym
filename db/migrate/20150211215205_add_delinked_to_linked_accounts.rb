class AddDelinkedToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :destroyed_at, :timestamp
  end
end
