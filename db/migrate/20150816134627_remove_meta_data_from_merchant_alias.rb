class RemoveMetaDataFromMerchantAlias < ActiveRecord::Migration
  def change
  	remove_column :merchant_aliases, :transaction_meta_data, :json
  	add_reference :merchant_aliases, :transaction
  end
end
