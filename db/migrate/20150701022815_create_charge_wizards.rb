class CreateChargeWizards < ActiveRecord::Migration
  def change
    create_table :charge_wizards do |t|
      t.json :progress
      t.boolean :in_progress
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
