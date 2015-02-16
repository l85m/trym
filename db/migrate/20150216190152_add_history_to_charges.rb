class AddHistoryToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :history, :hstore
  end
end
