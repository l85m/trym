class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.text :description
      t.belongs_to :user, index: true, foreign_key: true
      t.integer :amount
      t.date :start_date
      t.date :end_date
      t.integer :renewal_period_in_weeks
      t.date :billing_day
      t.boolean :wizard_complete
      t.date :last_date_billed
      t.belongs_to :merchant, index: true, foreign_key: true
      t.boolean :recurring
      t.integer :billed_to_date
      t.integer :recurring_score
      t.belongs_to :transaction_request, index: true, foreign_key: true
      t.belongs_to :linked_account, index: true, foreign_key: true
      t.belongs_to :trym_category, index: true, foreign_key: true
      t.hstore :history
      t.string :plaid_name

      t.timestamps null: false
    end
  end
end
