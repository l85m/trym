class Api::DocsController < ApplicationController

	def index
		@data = File.read("#{Rails.root}/public/swagger.json")
		render json: @data
	end

end