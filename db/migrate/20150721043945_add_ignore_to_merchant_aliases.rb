class AddIgnoreToMerchantAliases < ActiveRecord::Migration
  def change
    add_column :merchant_aliases, :ignore, :boolean, default: false, null: false
  end
end
