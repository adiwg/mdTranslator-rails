# Alaska Data Integration working group - ADIwg
# development team:
# 	U.S. Geological Survey - Alaska Science Center
#	U.S. Fish & Wildlife - Arctic Landscape Conservation Cooperative
#	Axiom Alaska Consulting
#	Nunatec Consulting

# REST endpoint controller

# History:
# 	Stan Smith 2013-08-09 proof of concept
#   Josh Bradley 2013-12-28 implementation of demo website
# 	Stan Smith 2014-09-05 migration to Rails 4.1.1 for implementation

# require 'adiwg-mdtranslator'
# require 'redcarpet'
# Don't require these in the controller, require is not multi-thread safe
# In general the gem should require itself automatically when using bundler and Gemfiles
# If for some reason it doesn't then you will need to add a custom require in one of two places.
# 1. Add a require: 'libfilename' to the Gemfile for the gem being loaded.
#     I.E.  gem 'adiwg-mdtranslator', require: 'adiwg-mdtranslator'
# 2. or add the require to the config/application.rb, this gets loaded once when the 
#     application starts which won't run into problems when running in a multi-threaded 
#     environment.

class V1Controller < ApplicationController

	skip_before_action :verify_authenticity_token

	markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

	# GETs
	def index
		readerName = params[:reader] if params[:reader]
		writerName = params[:writer] if params[:writer]
		if readerName == 'adiwgJson'
			render 'adiwgJsonR.html.erb'
		end
	end

	# POSTs
	# ...api/v1
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
		format = params[:format]

		# call the ADIwg metadata translator
		@mdReturn = ADIWG::Mdtranslator.translate(fileObj, readerName, writerName, validation, showAllTags)

		# return Content-Type is based on:
		# ...user requested content-type - params[:format]
		# ...native output of writer - @mdReturn[:writerFormat]
		# ...success or failure of translation

		# collect response content in a hash
		@responseInfo = {}
		@responseInfo[:data] = @mdReturn[:writerOutput]

		# check for validation errors and prepare messages
		aMessages = Array.new
		if @mdReturn[:readerStructurePass] && @mdReturn[:readerValidationPass]
			# no validation errors were detected
			@responseInfo[:success] = true
		else
			# some validation errors were detected
			@responseInfo[:success] = false

			# error messages must be handled individually because they may contain '[]' or '{}'
			# ...which confuse array methods
			unless @mdReturn[:readerStructurePass].nil?
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
			end

			unless @mdReturn[:readerValidationPass].nil?
				if @mdReturn[:readerValidationPass]
					aMessages << "Success - Input content passes schema definition\n"
				else
					aMessages << "Fail - Input content did not pass schema validation - see following message(s):\n"
					@mdReturn[:readerValidationMessages].each do |message|
						aMessages << message.to_s
					end
				end
			end

		end

		@responseInfo[:messages] = aMessages

		case format
			when 'auto'
				# test validation was successful
				if @responseInfo[:success]
					case @mdReturn[:writerFormat]
						when 'xml'
							render xml: @mdReturn[:writerOutput]
						when 'json'
							render json: @mdReturn[:writerOutput]
						when nil
							# be sure writerFormat is nil because no writer was requested
							if writerName = ''
								render plain: 'Success'
							else
								s = ''
								s += "Warning - No validation errors were detected, but writer was not called\n"
								s += "Be sure writer name is valid\n"
								render plain: s
							end
					end
				else
					# validation error were found
					case @mdReturn[:writerFormat]
						when 'xml'
							request.format = 'xml'
							render 'create.xml.builder'
						when 'json'
							request.format = 'json'
							render 'create.json.erb'
						when nil
							request.format = 'plain'
							s = ''
							@responseInfo[:messages].each do |message|
								s += message + "\n"
							end
							render plain: s
					end
				end

			when 'plain'
				# test validation was successful
				if @responseInfo[:success]
					# writeFormat is not considered, all output is returned as text/plain
					render plain: @responseInfo[:data]
				else
					# validation errors were detected, just return the messages
					request.format = 'plain'
					s = ''
					@responseInfo[:messages].each do |message|
						s += message + "\n"
					end
					render plain: s
				end

			when 'json'
				# place response in json wrapper
				render 'create.json.erb'

			when 'xml'
				# place response in json wrapper
				render 'create.xml.builder'

		end

	end

end
