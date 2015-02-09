class FinancialInstitution < ActiveRecord::Base
	fuzzily_searchable :name

	has_many :linked_accounts
	has_many :users, through: :linked_accounts

	scope :connect_enabled, -> { where(connect: true) }
	scope :requires_mfa, -> { where(has_mfa: true) }

	def scan(user,pass,id)
		AmexScraper.perform_async(user,pass,id)
	end
end
