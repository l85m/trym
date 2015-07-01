class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    create_table :linked_accounts do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :financial_institution, index: true, foreign_key: true
      t.string :plaid_access_token
      t.datetime :last_successful_sync
      t.hstore :last_api_response
      t.text :mfa_question
      t.text :mfa_type
      t.datetime :destroyed_at
      t.text :status

      t.timestamps null: false
    end
  end
end
