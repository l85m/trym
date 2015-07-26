class AddTransactionMetaDataToMerchantAliases < ActiveRecord::Migration
  def change
    add_column :merchant_aliases, :transaction_meta_data, :json
  end
end
