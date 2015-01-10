class AddAmountCompleteToTransactionDataRequest < ActiveRecord::Migration
  def change
    add_column :transaction_data_requests, :amount_complete, :integer
  end
end
