class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.text :plaid_id, null: false
      t.text :name
      t.date :date
      t.integer :amount
      t.text :category_id
      t.references :charge, index: true
      t.references :merchant, index: true
      t.references :transaction_request, index: true
    end
    add_index :transactions, :category_id
    add_index :transactions, :plaid_id, unique: true
  end
end
