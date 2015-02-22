class PlaidCategory < ActiveRecord::Base

	def description
		if hierarchy.size > 1
			hierarchy[1]
		else
			hierarchy.first
		end
	end

end
