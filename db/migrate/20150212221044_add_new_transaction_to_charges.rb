class AddNewTransactionToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :new_transaction, :boolean, default: false, null: false
  end
end
