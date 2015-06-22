class AddLogoToFinancialInstitution < ActiveRecord::Migration
  def change
    add_column :financial_institutions, :logo, :string
  end
end
