class CreateAccountDetails < ActiveRecord::Migration
  def change
    create_table :account_details do |t|
      t.references :user, index: true
      t.text :first_name
      t.text :last_name
      t.text :phone

      t.timestamps
    end
  end
end
