# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial

class Api::V1::DemosController < ApplicationController

		# GET /tests
		def show
			file = File.open('lib/assets/adiwgJson_full_test_example.json', 'r')
			@jsonDemo = file.read
			file.close
		end

end