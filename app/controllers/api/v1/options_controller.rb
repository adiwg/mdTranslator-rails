# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2013-10-09 initial

class Api::V1::OptionsController < ApplicationController

	skip_before_action :verify_authenticity_token

	# GETs

	def show
		# return json formatted list of options
		@options = Option.getOptionList
		if params[:callback] == ''
			render json: @options
		else
			render json: @options, callback: params[:callback]
		end
	end

end