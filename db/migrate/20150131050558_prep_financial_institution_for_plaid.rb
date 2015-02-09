class PrepFinancialInstitutionForPlaid < ActiveRecord::Migration
  def change
  	change_table :financial_institutions do |t|
  		t.remove :read_enabled
  		t.remove :website
  		t.string :type
  		t.boolean :has_mfa
  		t.string :mfa, array: true
  	end
  end
end
