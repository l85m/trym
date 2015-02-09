class CorrectLinkedAccountIdOnCharges < ActiveRecord::Migration
  def change
  	remove_column :charges, :linked_accounts_id, :integer
  	add_reference :charges, :linked_account, index: true
  end
end
