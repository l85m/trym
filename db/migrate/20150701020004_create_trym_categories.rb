class CreateTrymCategories < ActiveRecord::Migration
  def change
    create_table :trym_categories do |t|
      t.string :name
      t.boolean :recurring
      t.text :description

      t.timestamps null: false
    end
  end
end
