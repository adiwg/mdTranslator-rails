# Alaska Data Integration working group - ADIwg
# development team:
# 	U.S. Geological Survey - Alaska Science Center
#	U.S. Fish & Wildlife - Arctic Landscape Conservation Cooperative
#	Axiom Alaska Consulting
#	Nunatec Consulting

# REST endpoint controller for ruby gem adiwg-mdtranslator

# History:
# 	Stan Smith 2013-08-09 proof of concept
#   Josh Bradley 2013-12-28 implementation of demo website
# 	Stan Smith 2014-09-05 migration to Rails 4.1.1 for implementation
#   Stan Smith 2014-10-09 implemented changes suggested by Will Fisher, UAF
#   Stan Smith 2014-10-09 version 1 ready
#   Stan Smith 2014-11-10 routed empty endpoint api/v1/codelists to api/codelists
#   Stan Smith 2014-11-10 return all messageObject detail when
#   ... mdTranslator returns error messages
#   Stan Smith 2014-11-10 remove absolute path information from error messages

class Api::V1::TranslatorsController < ApplicationController

	# Gets
	# not supported

	# POSTs
	# ...api/v1/translator
	def create

		# load file and parameter from POST
		fileObj = params[:file]
		readerName = params[:reader]
		writerName = params[:writer]
		validation = params[:validate]
		showAllTags = false
		if params[:showAllTags] == 'true'
			showAllTags = true
		end
		format = 'auto'
		format = params[:format] if params[:format]

		# call the ADIwg metadata translator
		@mdReturn = ADIWG::Mdtranslator.translate(fileObj, readerName, writerName, validation, showAllTags)

		# return Content-Type is based on:
		# ...user requested content-type - params[:format]
		# ...native output of writer - @mdReturn[:writerFormat]
		# ...success or failure of translation

		# collect response content in a hash
		@responseInfo = {}
		@responseInfo[:success] = nil
		@responseInfo[:messages] = {}
		@responseInfo[:data] = nil

		# load the data returned from the translator into the response
		@responseInfo[:data] = @mdReturn[:writerOutput]

		# check for validation errors and prepare messages
		aMessages = Array.new
		if @mdReturn[:readerStructurePass] && @mdReturn[:readerValidationPass]
			# no validation errors were detected
			@responseInfo[:success] = true
		else
			# some validation errors were detected
			# no input was passed to the translator
			# no output was received
			@responseInfo[:success] = false

			# pass supplemental information back to assist in error resolution
			# drop output from the supplemental information
			# rewrite message to
			# ... shorten structure message to 1000 characters
			# ... remove absolute paths from validation messages
			@responseInfo[:messages] = @mdReturn
			@responseInfo[:messages].delete(:writerOutput)

			# error messages must be handled individually because some contain '[]' or '{}'
			# ...which confuses the array methods
			unless @mdReturn[:readerStructurePass].nil?
				aMessages = []
				if @mdReturn[:readerStructurePass]
					aMessages << "Success - Input structure is valid\n"
				else
					aMessages << "Fail - Structure of input file is invalid - see following message(s):\n"
					@mdReturn[:readerStructureMessages].each do |message|
						# parser returns entire input file if there is a structure error
						# the file is not marked where the error occurs,
						# so the message is not helpful and therefore truncated to 1000 characters
						s = message.to_s.slice!(0,1000)
						if s.length == 1000
							s += ' ...'
						end
						aMessages << s
					end
				end
				@responseInfo[:messages][:readerStructureMessages] = aMessages
			end

			unless @mdReturn[:readerValidationPass].nil?
				aMessages = []
				if @mdReturn[:readerValidationPass]
					aMessages << "Success - Input content passes schema definition\n"
				else
					aMessages << "Fail - Input content did not pass schema validation - see following message(s):\n"

					# find path to remove from messages
					spec = Gem::Specification.find_by_name('adiwg-json_schemas')
					gem_root = spec.gem_dir
					gem_path = File.join(gem_root, 'schema')
					gem_path[0] = gem_path[0].downcase

					# replace gem_path in messages
					@mdReturn[:readerValidationMessages].each do |hMessage|
						sMessage = hMessage.to_s
						sMessage = sMessage.gsub(gem_path, '...')
						aMessages << sMessage
					end
				end
				@responseInfo[:messages][:readerValidationMessages] = aMessages
			end

		end

		case format
			when 'auto'
				# test validation was successful
				if @responseInfo[:success]
					case @mdReturn[:writerFormat]
						when 'xml'
							if params[:callback] == ''
								render xml: @mdReturn[:writerOutput]
							else
								render json: @mdReturn[:writerOutput], callback: params[:callback]
							end

						when 'json'
							if params[:callback] == ''
								render json: @mdReturn[:writerOutput]
							else
								render json: @mdReturn[:writerOutput], callback: params[:callback]
							end

						when nil
							# be sure writerFormat was returned nil because no writer was requested
							if writerName == ''
								if params[:callback] == ''
									render plain: 'Success'
								else
									render json: 'Success', callback: params[:callback]
								end
							else
								s = ''
								s += "Warning - No validation errors were detected, but writer was not called\n"
								s += "Be sure writer name is valid\n"
								if params[:callback] == ''
									render plain: s
								else
									render json: s, callback: params[:callback]
								end
							end

					end
				else
					# validation error were found and will be returned
					# validation errors usually caught before entering the writer
					# so if there are validations the writerFormat will generally be nil
					case @mdReturn[:writerFormat]
						when nil
							request.format = 'plain'
							s = ''
							@responseInfo[:messages].each do |message|
								s += message + "\n"
							end
							if params[:callback] == ''
								render plain: s
							else
								render json: s, callback: params[:callback]
							end

						when 'xml'
							# if errors were detected by an XML writer
							# the iso19115_2 XML writer does not error check at this time
							# this is an unused path
							render 'create.xml.builder'

						when 'json'
							# if errors were detected by a JSON writer
							# no JSON writer are available at this time
							# this is an unused path
							render json: @responseInfo[:data]
					end
				end

			when 'plain'
				# test validation was successful
				if @responseInfo[:success]
					# writeFormat is not considered, all output is returned as text/plain
					if params[:callback] == ''
						render plain: @responseInfo[:data]
					else
						render json: @responseInfo[:data], callback: params[:callback]
					end

				else
					# validation errors were detected, just return the messages
					request.format = 'plain'
					s = ''
					@responseInfo[:messages].each do |message|
						s += message + "\n"
					end
					if params[:callback] == ''
						render plain: s
					else
						render json: s, callback: params[:callback]
					end
				end

			when 'json'
				# place response in json wrapper
				if params[:callback] == ''
					render json: @responseInfo
				else
					render json: @responseInfo, callback: params[:callback]
				end

			when 'xml'
				# place response in json wrapper
				if params[:callback] == ''
					render xml: @responseInfo
				else
					render json: @responseInfo, callback: params[:callback]
				end

		end

	end
end