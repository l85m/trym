class TransactionRequest < ActiveRecord::Base
  belongs_to :linked_account
end
