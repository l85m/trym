class ChangeMerchantToMerchantIdOnCharges < ActiveRecord::Migration
  def change
  	remove_column :charges, :merchant
  	add_reference :charges, :merchant
  end
end
