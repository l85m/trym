class CreateAccountDetails < ActiveRecord::Migration
  def change
    create_table :account_details do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.datetime :phone_verified_at
      t.string :confirmation_code
      t.hstore :account_data

      t.timestamps null: false
    end
  end
end
