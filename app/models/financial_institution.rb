class FinancialInstitution < ActiveRecord::Base
	fuzzily_searchable :name

	def scan(user,pass,id)
		AmexScraper.perform_async(user,pass,id)
	end
end
