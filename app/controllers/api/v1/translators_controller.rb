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
#   Josh Bradley 2014-11-12 fix message output for plain response
#   Stan Smith 2015-01-16 changed ADIWG::Mdtranslator.translate() to keyword parameter list
#   Stan Smith 2015-03-03 clean up of error message handling
#   Stan Smith 2015-03-03 return error message in plain text when 'auto' selected

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
		@mdReturn = ADIWG::Mdtranslator.translate(
			file: fileObj, reader: readerName, validate: validation,
			writer: writerName, showAllTags: showAllTags)

		# return Content-Type is based on:
		# ...user requested content-type - params[:format]
		# ...native output of writer - @mdReturn[:writerFormat]
		# ...success or failure of mdTranslator validation of input

		# construct a hash to collect response content
		@responseInfo = {}
		@responseInfo[:success] = nil
		@responseInfo[:messages] = {}
		@responseInfo[:data] = nil

		# load any output returned from mdTranslator into the response hash
		@responseInfo[:data] = @mdReturn[:writerOutput]

		# check for errors returned by parser, validator, reader, and writer
		if @mdReturn[:readerStructurePass] && @mdReturn[:readerValidationPass] && @mdReturn[:readerExecutionPass] && @mdReturn[:writerPass]
			# no validation errors were detected
			@responseInfo[:success] = true
		else
			# errors messages were returned by mdTranslator's parser, validator, reader, or writer
			@responseInfo[:success] = false

			# pass all information received from the mdTranslator to the requester
			# ... to assist in error resolution
			# ... remove absolute paths from validation messages
			@responseInfo[:messages] = @mdReturn

            # handling of parser errors
            if @mdReturn[:readerStructurePass]
                @responseInfo[:messages][:readerStructureMessages].insert(0, "Success - Input structure is valid\n")
            else
                @responseInfo[:messages][:readerStructureMessages].insert(0,"Fail - Structure of input file is invalid - see following message(s):\n")
            end

            # handling validator messages
            if @mdReturn[:readerValidationPass].nil?
                @responseInfo[:messages][:readerValidationMessages].insert(0, "Validator was not called\n")
            elsif @mdReturn[:readerValidationPass]
                @responseInfo[:messages][:readerValidationMessages].insert(0, "Success - Input content passes schema definition\n")
            else
                # the json schema validator returns full expanded paths to gem
                # these full paths may pose a security risk and are removed from the messages
                # find gem path to remove from messages
                gem_root = ADIWG::MdjsonSchemas::Utils.schema_dir.match(/(^.+)\/lib/i).captures[0]
                gem_path = File.join(gem_root, 'schema')
                gem_path[0] = gem_path[0].downcase

                # replace gem_path in messages with '...'
                aMessages = []
                @mdReturn[:readerValidationMessages].each do |hMessage|
                    sMessage = hMessage.to_s
                    sMessage = sMessage.gsub(gem_path, '...')
                    aMessages << sMessage
                end
                @responseInfo[:messages][:readerValidationMessages] = aMessages

                @responseInfo[:messages][:readerValidationMessages].insert(0, "Fail - Input content did not pass schema validation - see following message(s):\n")
            end

            # handling reader messages
            if @mdReturn[:readerExecutionPass].nil?
                @responseInfo[:messages][:readerExecutionMessages].insert(0, "Reader was not called\n")
            elsif @mdReturn[:readerExecutionPass]
                @responseInfo[:messages][:readerExecutionMessages].insert(0, "Success - Input file was read\n")
            else
                @responseInfo[:messages][:readerExecutionMessages].insert(0,"Fail - Reading of input file did not complete  - see following message(s):\n")
            end

            # handling of writer messages
            if @mdReturn[:writerPass].nil?
                @responseInfo[:messages][:writerMessages].insert(0, "Writer was not called\n")
            elsif @mdReturn[:writerPass]
                @responseInfo[:messages][:writerMessages].insert(0, "Success - Metadata file was created\n")
            else
                @responseInfo[:messages][:writerMessages].insert(0,"Fail - Creation of metadata file failed to complete  - see following message(s):\n")
            end

		end

		case format
			when 'auto'
				if @responseInfo[:success]
					# there were no validation errors
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
					# errors were found and will be returned to requester
					# return plain text
                    request.format = 'plain'
                    s = ''
                    messages = ActiveSupport::HashWithIndifferentAccess.new(@responseInfo[:messages])
                    messages.each do |key, message|
                        s += (key + ': ' + message.to_s + "\n")
                    end
                    if params[:callback] == ''
                        render plain: s
                    else
                        render json: s, callback: params[:callback]
                    end

                end


			when 'plain'
				# text/plain was requested
				# ... writeFormat is not considered
				# all output to be returned as text/plain
				# ... or JSONp if callback requested
				if @responseInfo[:success]
					# there were no validation errors
					if params[:callback] == ''
						render plain: @responseInfo[:data]
					else
						render json: @responseInfo[:data], callback: params[:callback]
					end

				else
					# errors were found and will be returned to requester
					s = ''
					messages = ActiveSupport::HashWithIndifferentAccess.new(@responseInfo[:messages])
					messages.each do |key, message|
						s += (key + ': ' + message.to_s + "\n")
					end
					if params[:callback] == ''
						render plain: s
					else
						render json: s, callback: params[:callback]
					end
				end

			when 'json'
				# application/json was requested
				# ... writeFormat is not considered
				# ... mdTranslator success status is not considered
				# full response from mdTranslator to be returned in json wrapper
				# ... or returned as JSONp if callback requested
				if params[:callback] == ''
					render json: @responseInfo
				else
					render json: @responseInfo, callback: params[:callback]
				end

			when 'xml'
				# application/xml was requested
				# ... writeFormat is not considered
				# ... mdTranslator success status is not considered
				# full response from mdTranslator to be returned in xml wrapper
				# ... or returned as JSONp if callback requested
				if params[:callback] == ''
					render xml: @responseInfo
				else
					render json: @responseInfo, callback: params[:callback]
				end

		end

	end
end