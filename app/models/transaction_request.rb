class TransactionRequest < ActiveRecord::Base
  belongs_to :linked_account
  has_many :charges

end