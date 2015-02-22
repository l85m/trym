class TrymCategory < ActiveRecord::Base
	validates_presence_of :name, :recurring
	validates_uniqueness_of :name

	has_many :plaid_categories
	has_many :merchants

	def charges
		t = Charge.arel_table

		Charge.where( t[:merchant_id].in(merchants.pluck(:id)).or( t[:category_id].in(plaid_categories.pluck(:plaid_id)) ) )
	end
end
