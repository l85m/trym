class ChangeDataOnTransactionRequests < ActiveRecord::Migration
  def change
  	remove_column :transaction_requests, :data, :string
  	add_column :transaction_requests, :data, :json
  end
end
