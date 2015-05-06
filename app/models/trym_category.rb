class TrymCategory < ActiveRecord::Base
	validates_presence_of :name, :recurring
	validates_uniqueness_of :name

	has_many :plaid_categories
	has_many :merchants

	scope :recurring, -> { where(recurring: true) }

	def self.merchant_select
		#put TV, Magazines, and Gyms in front
		Rails.cache.fetch("merchant_select", expires_in: 12.hours) do
				TrymCategory.order("id=2 DESC, id=5 DESC, id=1 DESC, name DESC").collect do |c| 
				if c.merchants.present?
					[ { id: nil, text: nil, category: c.name} ] +
					c.merchants.order(:name).pluck(:name, :id).collect{ |name, id| {id: id, text: name, category: c.name} }
				else
					nil
				end
			end.compact.flatten.to_json
		end
	end

	def charges
		t = Charge.arel_table

		Charge.where( t[:trym_category_id].eq(id).or(
				t[:trym_category_id].eq(nil).and( t[:merchant_id].in(merchants.pluck(:id))).or(
					t[:merchant_id].in([nil] + Merchant.not_categorized.pluck(:id)).and( t[:category_id].in(plaid_categories.pluck(:plaid_id)))
				)
			)
		)
	end

end
