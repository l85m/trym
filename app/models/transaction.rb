class Transaction < ActiveRecord::Base
  belongs_to :transaction_request
  belongs_to :charge
  belongs_to :plaid_category, foreign_key: :category_id, primary_key: :plaid_id
  belongs_to :merchant
end