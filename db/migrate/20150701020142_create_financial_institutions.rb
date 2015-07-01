class CreateFinancialInstitutions < ActiveRecord::Migration
  def change
    create_table :financial_institutions do |t|
      t.string :name
      t.string :plaid_type
      t.boolean :has_mfa
      t.string :mfa
      t.string :plaid_id
      t.boolean :connect

      t.timestamps null: false
    end
  end
end
