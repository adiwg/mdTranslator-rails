# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial
#   Stan Smith 2014-10-10 import show text body from mdTranslator readme file

class Api::ReadersController < ApplicationController

	# GET
	# .../api/readers
	def index
		respond_to do |format|
			format.html
		end
	end

	# .../api/readers/{:id}
	def show
		@reader = params[:id]

		# get text for shhow body from mdTranslator readme file
		path = ADIWG::Mdtranslator.path_to_resources
		file = File.open(File.join(path, 'readers', @reader, 'readme.txt'), 'r')
		@readerBody = file.read
		file.close
	end

end