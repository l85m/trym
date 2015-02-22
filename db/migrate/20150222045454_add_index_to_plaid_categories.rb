class AddIndexToPlaidCategories < ActiveRecord::Migration
  def change
    add_index :plaid_categories, :plaid_id, unique: true
  end
end
