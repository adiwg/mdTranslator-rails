# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
#  Stan Smith 2017-05-19 refactored for mdTranslator 2.0
# 	Josh Bradley 2015-02-27 use schema example
# 	Stan Smith 2014-10-09 initial

class Api::V2::DemosController < ApplicationController

   # GET /tests
   def show
      file = File.join(ADIWG::MdjsonSchemas::Utils.examples_dir, 'mdJson.json')
      file = File.open(file, 'r')
      @mdJsonDemo = file.read
      file.close

      file = File.join(File.dirname(__FILE__), '../../../assets/samples', 'fgdc.xml')
      file = File.open(file, 'r')
      @fgdcDemo = file.read
      file.close

      file = File.join(File.dirname(__FILE__), '../../../assets/samples', 'sbJson.json')
      file = File.open(file, 'r')
      @sbJsonDemo = file.read
      file.close
   end

end