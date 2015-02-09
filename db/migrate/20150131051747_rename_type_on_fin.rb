class RenameTypeOnFin < ActiveRecord::Migration
  def change
  	rename_column :financial_institutions, :type, :plaid_type
  end
end
