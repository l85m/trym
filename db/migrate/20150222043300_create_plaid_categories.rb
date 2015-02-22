class CreatePlaidCategories < ActiveRecord::Migration
  def change
    create_table :plaid_categories do |t|
      t.string :plaid_type
      t.string :hierarchy, array:true
      t.string :plaid_id

      t.timestamps
    end
  end
end
