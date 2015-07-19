class Merchant < ActiveRecord::Base
	has_many :charges
	has_many :notes, as: :noteable

	belongs_to :trym_category

	validates_uniqueness_of :name, conditions: -> { where( validated: true ) }
	validates_presence_of :name

	fuzzily_searchable :name

	scope :validated, -> {where(validated: true)}
	scope :not_validated, -> {where(validated: false)}
	scope :not_categorized, -> {where(trym_category_id: nil)}
	scope :categorized, -> {where.not(trym_category_id: nil)}


	def self.find_by_fuzzy_name_with_similar_threshold(query, threshold = 80)
		query = query.downcase.gsub(/[^0-9a-z ]/i, '')
		result = find_by_fuzzy_name(query).select(&:validated).first rescue nil
		if result.present?
			result_name = result.name.downcase.gsub(/[^0-9a-z ]/i, '')
			if ( result_name.similar(query) >= threshold || ( [query.size,result_name.size].min > 4 && ( query.include?(result_name) || result_name.include?(query) ) ) )
				result
			else
				nil
			end
		else
			nil
		end
	end

	def self.selection_search(query=nil, category_id=nil)
		return TrymCategory.merchant_select unless query.present?

		if category_id.present?
			r = find_by_fuzzy_name(query, limit: 5).
					reject{ |m| m.trym_category_id != category_id.to_i }.
					select(&:validated)
		else
			r = find_by_fuzzy_name(query, limit: 5).
					select(&:validated)
		end 
		r = r.present? ? r.collect{ |m| { id: m.id, text: m.name, category: m.trym_category_name } } : []
		(r + [{ id: query, text: "New Provider: " + query, category: nil }]).to_json
	end

	def required_cancelation_fileds
		(cancelation_fields.presence || {}).select{ |_,a| a["required"] }.keys
	end

	def reusable_cancelation_fields
		(cancelation_fields.presence || {}).select{ |_,a| a["reusable"] }.keys
	end

	def trym_category_name
		trym_category.present? ? trym_category.name : nil
	end

end