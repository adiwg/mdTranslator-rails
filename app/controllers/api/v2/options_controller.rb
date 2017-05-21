# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial

class Api::V2::OptionsController < ApplicationController

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