class ChangeOwnershipOfChargeWizard < ActiveRecord::Migration
  def change
  	remove_reference :charge_wizards, :linked_account, index: true
  	add_reference :charge_wizards, :user, index: true
  end
end
