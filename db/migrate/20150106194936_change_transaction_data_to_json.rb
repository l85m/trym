class ChangeTransactionDataToJson < ActiveRecord::Migration
  def change
		remove_column :transaction_data_requests, :transaction_data
  	add_column :transaction_data_requests, :transaction_data, :json
  end
end
