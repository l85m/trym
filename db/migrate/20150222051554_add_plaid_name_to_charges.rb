class AddPlaidNameToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :plaid_name, :string
  end
end
