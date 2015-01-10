class CreateFinancialInstitutions < ActiveRecord::Migration
  def change
    create_table :financial_institutions do |t|
      t.string :name
      t.string :website
      t.boolean :read_enabled

      t.timestamps
    end
  end
end
