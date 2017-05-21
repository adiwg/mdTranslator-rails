# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
#  Stan Smith 2014-10-11 changed method of getting readme text from mdTranslator
#  Stan Smith 2014-10-10 get text body for 'show' from mdTranslator readme file
# 	Stan Smith 2014-10-09 initial

class Api::WritersController < ApplicationController

   # GET
   # .../api/writers
   def index
      respond_to do |format|
         format.html
      end
   end

   # .../api/writer/{:id}
   def show
      # get text for show body from mdTranslator readme file
      @writer = params[:id]
      @writerBody = ADIWG::Mdtranslator::Writers.get_writer_readme(@writer)
   end

end