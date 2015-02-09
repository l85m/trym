class ChangeStatusOnLinkedAccounts < ActiveRecord::Migration
  def change
  	remove_column :linked_accounts, :status, :string
  	add_column :linked_accounts, :last_api_response, :hstore
  end
end
