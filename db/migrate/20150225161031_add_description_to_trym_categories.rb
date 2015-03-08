class AddDescriptionToTrymCategories < ActiveRecord::Migration
  def change
    add_column :trym_categories, :description, :text
  end
end
