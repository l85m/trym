class CreateTransactionDataRequests < ActiveRecord::Migration
  def change
    create_table :transaction_data_requests do |t|
      t.references :user, index: true, null: false
      t.references :financial_institution, index: true, null: false
      t.string :status
      t.hstore :failure_reason

      t.timestamps
    end
  end
end
