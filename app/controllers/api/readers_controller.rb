# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial
#   Stan Smith 2014-10-10 get text body for 'show' from mdTranslator readme file
#   Stan Smith 2014-10-11 changed method of getting readme text from mdTranslator

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
		# get text for show body from mdTranslator readme file
		@reader = params[:id]
		@readerBody = ADIWG::Mdtranslator.get_reader_readme(@reader)
	end

end