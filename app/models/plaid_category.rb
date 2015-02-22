class PlaidCategory < ActiveRecord::Base
	has_many :charges, foreign_key: :category_id, primary_key: :plaid_id
	belongs_to :trym_category

	def description
		if hierarchy.size > 1
			hierarchy[1]
		else
			hierarchy.first
		end
	end

end
