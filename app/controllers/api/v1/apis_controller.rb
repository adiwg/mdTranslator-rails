# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2013-10-09 initial

class Api::V1::ApisController < ApplicationController

	# GET
	# .../api/v1/
	# .../api/v1/api
	def show
		respond_to do |format|
			format.html
		end
	end

end