class AddLastDateBilledToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :last_date_billed, :date
  end
end
