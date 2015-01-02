class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.text :merchant
      t.text :description
      t.references :user, index: true
      t.integer :amount
      t.date :start
      t.date :end
      t.integer :renewal_period_in_days

      t.timestamps
    end
  end
end
