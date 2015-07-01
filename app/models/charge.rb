class Charge < ActiveRecord::Base
  belongs_to :user
  belongs_to :merchant
  belongs_to :transaction_request
  belongs_to :linked_account
  belongs_to :trym_category
end
