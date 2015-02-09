class CreateTransactionRequests < ActiveRecord::Migration
  def change
    create_table :transaction_requests do |t|
      t.references :linked_account
      t.string :data, array: true
    end
    add_reference :charges, :transaction_requests, index: true
    remove_column :linked_accounts, :transaction_data
  end
end
