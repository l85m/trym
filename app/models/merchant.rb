class Merchant < ActiveRecord::Base
	has_many :charges
	has_many :notes, as: :noteable

	validates_uniqueness_of :name, conditions: -> { where( validated: true ) }
	fuzzily_searchable :name

	scope :validated, -> {where(validated: true)}

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

	def self.selection_search(query)
		find_by_fuzzy_name(query, limit: 5).select(&:validated) + [OpenStruct.new(id: query, name: "New: " + query)]
	end

end