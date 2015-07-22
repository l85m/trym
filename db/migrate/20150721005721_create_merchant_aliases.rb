class CreateMerchantAliases < ActiveRecord::Migration
  def change
    create_table :merchant_aliases do |t|
      t.string :alias, null: false
      t.references :merchant, index: true
      t.references :financial_institution, index: true, null: false

      t.timestamps
    end
    add_index :merchant_aliases, :alias
  end
end
