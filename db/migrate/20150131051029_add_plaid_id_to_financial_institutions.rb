class AddPlaidIdToFinancialInstitutions < ActiveRecord::Migration
  def change
    add_column :financial_institutions, :plaid_id, :string
  end
end
