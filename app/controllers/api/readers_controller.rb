# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2013-10-09 initial

class Api::ReadersController < ApplicationController

	# GET /api/readers
	def index
		respond_to do |format|
			format.html
		end
	end

end