class TrymCategory < ActiveRecord::Base
	validates_presence_of :name, :recurring
	validates_uniqueness_of :name

	has_many :plaid_categories
	has_many :merchants

	scope :recurring, -> { where(recurring: true) }

	def self.merchant_select
		TrymCategory.all.collect{ |c| [c.name, c.merchants.order(:name).pluck(:name, :id)] }.to_h
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
