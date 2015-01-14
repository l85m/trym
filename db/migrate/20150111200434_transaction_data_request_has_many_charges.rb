class TransactionDataRequestHasManyCharges < ActiveRecord::Migration
  def change
  	add_reference :charges, :transaction_data_request, index: true
  	add_column :charges, :recurring, :boolean
  	add_column :charges, :billed_to_date, :integer
  	add_index :charges, :recurring, where: "recurring = true"
  end
end
