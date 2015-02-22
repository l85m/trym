class CreateChargeWizards < ActiveRecord::Migration
  def change
    create_table :charge_wizards do |t|
      t.references :linked_account, index: true
      t.references :user, index: true
      
      t.json :progress
      t.boolean :in_progress

      t.timestamps
    end
    rename_column :charges, :active, :wizard_complete
  end
end
