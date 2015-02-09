class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    rename_table :transaction_data_requests, :linked_accounts
    remove_column :charges, :transaction_data_request_id
    add_reference :charges, :linked_accounts
  end
end
