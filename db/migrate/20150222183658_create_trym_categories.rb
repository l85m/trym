class CreateTrymCategories < ActiveRecord::Migration
  def change
    create_table :trym_categories do |t|
      t.string :name, null: false
      t.boolean :recurring, default: false, null: false

      t.timestamps
    end
    add_reference :plaid_categories, :trym_category, index: true
    add_reference :merchants, :trym_category, index: true
  end
end
