class AddCategoryIdToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :category_id, :string
  end
end
