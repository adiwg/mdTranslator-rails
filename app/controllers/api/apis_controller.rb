# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
#  Stan Smith 2017-05-19 move api out of v2
# 	Stan Smith 2014-10-09 original script

class Api::ApisController < ApplicationController

   # GET
   # .../api/
   # .../api/api
   def show
      respond_to do |format|
         format.html
      end
   end

end