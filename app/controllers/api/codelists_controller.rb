# Alaska Data Integration working group - ADIwg

# REST endpoint controller for return of codeLists

# History:
# 	Stan Smith 2014-11-03 initial
#   Stan Smith 2014-11-07 added namesOnly option

class Api::CodelistsController < ApplicationController

	# GETs
	def index
		# return the all codeLists
		if params[:namesOnly] == 'true'
			@codeLists = ADIWG::Mdcodes.getCodeNames
		else
			@codeLists = ADIWG::Mdcodes.getCodeLists
		end

		format = 'json'
		format = params[:format] if params[:format]

		if format == 'json'
			if params[:callback] == ''
				render json: @codeLists
			else
				render json: @codeLists, callback: params[:callback]
			end
		end
		if format == 'xml'
			render(:template => 'api/codelists/index', :formats => [:xml], :handlers => :builder, :layout => false)
		end
	end

	def show
		# return individual codeList
		# only returns in JSON or JSONp
		if params[:namesOnly] == 'true'
			@codeList = ADIWG::Mdcodes.getCodeName(params[:id])
		else
			@codeList = ADIWG::Mdcodes.getCodeList(params[:id])
		end

		if params[:callback] == ''
			render json: @codeList
		else
			render json: @codeList, callback: params[:callback]
		end
	end

end