# Alaska Data Integration working group - ADIwg

# REST endpoint controller for return of codeLists

# History:
# 	Stan Smith 2014-11-03 initial
#   Stan Smith 2014-11-07 added namesOnly option
#   Stan Smith 2014-12-04 changed option 'namesOnly' to 'definitions'
#   Stan Smith 2014-12-18 method name changes in Mdcodes

class Api::CodelistsController < ApplicationController

	# GETs
	def index
		# return the all codeLists
		# set default format to json
		format = 'json'
		format = params[:format] if params[:format]

		# if format is xml return an ISO CT_CodelistCatalogue version of the codelists
		if format == 'xml'
			@codeLists = ADIWG::Mdcodes.getAllCodeistsDetail
			render(:template => 'api/codelists/index', :formats => [:xml], :handlers => :builder, :layout => false)
		else
			# return list in the default JSON format
			# get the codelist or codelist with definitions depending on parameters
			if params[:definitions] == 'true'
				@codeLists = ADIWG::Mdcodes.getAllCodeistsDetail
			else
				@codeLists = ADIWG::Mdcodes.getAllStaticCodelists
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
		if params[:definitions] == 'true'
			@codeList = ADIWG::Mdcodes.getCodelistDetail(params[:id])
		else
			@codeList = ADIWG::Mdcodes.getStaticCodelist(params[:id])
		end

		if params[:callback] == ''
			render json: @codeList
		else
			render json: @codeList, callback: params[:callback]
		end
	end

	private

end