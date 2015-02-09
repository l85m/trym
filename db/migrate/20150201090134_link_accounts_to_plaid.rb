class LinkAccountsToPlaid < ActiveRecord::Migration
  def change
  	change_table :linked_accounts do |t|
  		t.remove :failure_reason
  		t.remove :transaction_data
  		t.remove :amount_complete
  		t.string :plaid_access_token
  		t.timestamp :last_successful_sync
  	end
  end
end
