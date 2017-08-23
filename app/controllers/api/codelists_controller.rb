# Alaska Data Integration working group - ADIwg

# REST endpoint controller for return of codeLists

# History:
#  Stan Smith 2014-12-18 method name changes in Mdcodes
#  Stan Smith 2014-12-04 changed option 'namesOnly' to 'definitions'
#  Stan Smith 2014-11-07 added namesOnly option
# 	Stan Smith 2014-11-03 initial code

class Api::CodelistsController < ApplicationController

   # GETs
   def index
      # return all codeLists
      # set default format to json
      format = 'json'
      showDeprecated = false
      format = params[:format] if params[:format]
      if params[:showDeprecated]
         showDeprecated = true if params[:showDeprecated] == 'true'
         showDeprecated = false if params[:showDeprecated] == 'false'
      end

      # if format is xml format return codelists as an ISO CT_CodelistCatalogue
      if format == 'xml'
         @codeLists = ADIWG::Mdcodes.getAllCodelistsDetail
         render(:template => 'api/codelists/index', :formats => [:xml], :handlers => :builder, :layout => false)
      else
         # return list in the default JSON format
         # get the codelist or codelist with definitions depending on parameters
         if params[:definitions] == 'true'
            @codeLists = ADIWG::Mdcodes.getAllCodelistsDetail('json', showDeprecated)
         else
            @codeLists = ADIWG::Mdcodes.getAllStaticCodelists('json', showDeprecated)
         end

         if params[:callback] == ''
            render json: @codeLists
         else
            render json: @codeLists, callback: params[:callback]
         end
      end
   end

   def show
      # return individual codeList
      # only returns in JSON or JSONp
      showDeprecated = false
      if params[:showDeprecated]
         showDeprecated = true if params[:showDeprecated] == 'true'
         showDeprecated = false if params[:showDeprecated] == 'false'
      end
      if params[:definitions] == 'true'
         @codeList = ADIWG::Mdcodes.getCodelistDetail(params[:id], 'json', showDeprecated)
      else
         @codeList = ADIWG::Mdcodes.getStaticCodelist(params[:id], 'json', showDeprecated)
      end

      if params[:callback] == ''
         render json: @codeList
      else
         render json: @codeList, callback: params[:callback]
      end
   end

   private

end