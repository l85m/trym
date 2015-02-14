class TransactionRequest < ActiveRecord::Base
  belongs_to :linked_account
  has_many :charges

  def previous_transactions
  	TransactionRequest.where(linked_account_id: linked_account_id).where.not(id: id).collect do |r|
  		r.data.	collect{ |t| t.collect{ |k,v| [k.to_sym,v] }.to_h.merge({ new_transaction: false }) }
  	end.flatten
  end

end