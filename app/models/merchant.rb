class Merchant < ActiveRecord::Base
	has_many :charges
	has_many :notes, as: :noteable

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

end