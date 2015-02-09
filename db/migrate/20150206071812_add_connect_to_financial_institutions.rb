class AddConnectToFinancialInstitutions < ActiveRecord::Migration
  def change
    add_column :financial_institutions, :connect, :boolean
  end
end
