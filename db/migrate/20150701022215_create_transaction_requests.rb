class CreateTransactionRequests < ActiveRecord::Migration
  def change
    create_table :transaction_requests do |t|
      t.belongs_to :linked_account, index: true, foreign_key: true
      t.json :data

      t.timestamps null: false
    end
  end
end
