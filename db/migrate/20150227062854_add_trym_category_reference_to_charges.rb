class AddTrymCategoryReferenceToCharges < ActiveRecord::Migration
  def change
    add_reference :charges, :trym_category, index: true
  end
end
