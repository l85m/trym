class AddTimestampsToTransactionRequests < ActiveRecord::Migration
  def change
  	add_timestamps(:transaction_requests)
  end
end
