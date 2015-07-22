class MakeAliasIndexUniqueOnFinancialInsitution < ActiveRecord::Migration
  def change
  	remove_index :merchant_aliases, :alias
  	add_index :merchant_aliases, [:alias, :financial_institution_id], unique: true
  end
end
