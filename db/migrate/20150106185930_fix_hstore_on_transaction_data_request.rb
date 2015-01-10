class FixHstoreOnTransactionDataRequest < ActiveRecord::Migration
  def change
  	rename_column :transaction_data_requests, :failure_reason, :transaction_data
  	add_column :transaction_data_requests, :failure_reason, :string
  end
end
