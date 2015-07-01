class CreatePlaidCategories < ActiveRecord::Migration
  def change
    create_table :plaid_categories do |t|
      t.string :plaid_type
      t.string :hierarchy
      t.string :plaid_id
      t.belongs_to :trym_category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
