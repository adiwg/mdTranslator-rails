# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2013-10-09 initial

class Api::WritersController < ApplicationController

	# GET /api/writers
	def index
		respond_to do |format|
			format.html
		end
	end

	def show
		respond_to do |format|
			format.html
		end
	end

end