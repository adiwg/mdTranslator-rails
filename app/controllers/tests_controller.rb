# Alaska Data Integration working group - ADIwg
# development team:
# 	U.S. Geological Survey - Alaska Science Center
#	U.S. Fish & Wildlife - Arctic Landscape Conservation Cooperative
#	Axiom Alaska Consulting
#	Nunatec Consulting

# REST end point controller
# set options for testing post to /api/v1

class TestsController < ApplicationController

		# GET /tests
		def index
			file = File.open('lib/assets/adiwgJson_full_test_example.json', 'r')
			@jsonDemo = file.read
			file.close
		end

		def show
			@data = params[:id]
			respond_to do |format|
				format.html # show.html.erb
			end
		end

end