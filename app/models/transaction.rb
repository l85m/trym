class Transaction < ActiveRecord::Base
  belongs_to :transaction_request
  belongs_to :charge
  belongs_to :plaid_category, foreign_key: :category_id, primary_key: :plaid_id
  belongs_to :merchant

  def linked_account
  	transaction_request.linked_account
  end

  def financial_institution
  	linked_account.financial_institution
  end
  
end