class RemoveNewTransactionFromCharges < ActiveRecord::Migration
  def change
  	remove_column :charges, :new_transaction, :boolean
  end
end
