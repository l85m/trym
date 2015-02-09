class CorrectTransactionRequestsIdOnCharges < ActiveRecord::Migration
  def change
  	remove_column :charges, :transaction_requests_id, :integer
  	add_reference :charges, :transaction_request, index: true
  end
end
