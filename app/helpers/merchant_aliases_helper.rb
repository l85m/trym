module MerchantAliasesHelper
	def recurring_score_collection
		[["never recurring", -99], ["unlikely to recur", -5], ["unknown", 0], ["likely to recur", 2], ["very likely to recur", 5]].collect do |description, score|
			OpenStruct.new( description: description, score: score )
		end
	end

	def default_renewal_period
		[
			OpenStruct.new(period: 1, description: "Weekly - every week"),
	    OpenStruct.new(period: 2, description: "Bi-Weekly - every other week"),
	    OpenStruct.new(period: 4, description: "Monthly - once every month"),
	    OpenStruct.new(period: 8, description: "Bi-Monthly - every other month"),
	    OpenStruct.new(period: 12, description: "Quarterly - once every three months"),
	    OpenStruct.new(period: 16, description: "4-Monthly - once every four months"),
	    OpenStruct.new(period: 26, description: "Bi-Annually - twice a year"),
	    OpenStruct.new(period: 52, description: "Annually - once a year")
	  ]		
	end
end
