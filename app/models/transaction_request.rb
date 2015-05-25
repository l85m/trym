class TransactionRequest < ActiveRecord::Base
  belongs_to :linked_account
  has_many :charges

  def previous_transactions
  	previous_transactions = TransactionRequest.where(linked_account_id: linked_account_id).where.not(id: id)
  	return [] unless previous_transactions.present?
  	previous_transactions.collect do |r|
  		r.data.present? ? r.data.collect{ |t| t.collect{ |k,v| [k.to_sym,v] }.to_h } : []
  	end.flatten
  end

  def transaction_count
  	data.present? ? data.count : 0
  end

end