
class OptionsController < ApplicationController

	skip_before_action :verify_authenticity_token

	# GETs

	def index
		# return json formatted list of options
		@options = Option.getOptionList
		if params[:callback] == ''
			render json: @options
		else
			render json: @options, callback: params[:callback]
		end
	end

end