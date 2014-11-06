# Alaska Data Integration working group - ADIwg

# REST endpoint controller for return of codeLists

# History:
# 	Stan Smith 2014-11-03 initial

class Api::CodelistsController < ApplicationController

	# GETs
	def index
		# return the all codeLists
		@codeLists = ADIWG::Mdcodes.getCodeLists
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
		# only return in JSON or JSONp
		@codeLists = ADIWG::Mdcodes.getCodeList(params[:id])
		if params[:callback] == ''
			render json: @codeLists
		else
			render json: @codeLists, callback: params[:callback]
		end
	end

end