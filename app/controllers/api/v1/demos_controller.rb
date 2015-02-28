# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial
# 	Josh Bradley 2015-02-27 use schema example

class Api::V1::DemosController < ApplicationController

		# GET /tests
		def show
			file = File.open(File.join(ADIWG::MdjsonSchemas::Utils.examples_dir,'full_example.json'), 'r')
			@jsonDemo = file.read
			file.close
		end

end