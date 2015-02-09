class AddTransactionDataToLinkedAccount < ActiveRecord::Migration
  def change
  	add_column :linked_accounts, :transaction_data, :json
  end
end
