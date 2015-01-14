class Merchant < ActiveRecord::Base
	has_many :charges
	has_many :notes, as: :noteable
	fuzzily_searchable :name

	scope :has_website, -> {where.not(website: nil)}

	def self.names_and_websites
		has_website.order(:name).pluck(:name, :website).to_h
	end

	def self.find_or_create_by_name_or_website(name, website)
		if website.present?
			website = 'http://' + website unless website.match(/^http:\/\//)
			website = URI.parse(website).host.downcase
			merchant = Merchant.find_by_website(website)
			name = merchant.present? ? merchant.name : ( name.present? ? name.strip : nil )
		end
		find_or_create_by website: website, name: name
	end

	def self.find_by_fuzzy_name_with_similar_threshold(query, threshold = 70)
		result = find_by_fuzzy_name(query, limit: 1).first
		if result.present? && (result.name.similar(query) >= threshold || query.downcase.include?(result.name.downcase))
			result
		else
			nil
		end
	end

end