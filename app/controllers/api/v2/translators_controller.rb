# Alaska Data Integration working group - ADIwg
# development team:
# 	U.S. Geological Survey - Alaska Science Center
#	U.S. Fish & Wildlife - Arctic Landscape Conservation Cooperative
#	Axiom Alaska Consulting
#	Nunatec Consulting

# REST endpoint controller for ruby gem adiwg-mdtranslator

# History:
#  Stan Smith 2017-12-27 fix bug from rename of responseObj[:writerFormat] to [:writerOutputFormat]
#  Stan Smith 2017-05-19 refactored for mdTranslator 2.0
#  Stan Smith 2015-04-13 added html section to format='auto' for HTML writer
#  Stan Smith 2015-03-03 return error message in plain text when 'auto' selected
#  Stan Smith 2015-03-03 clean up of error message handling
#  Stan Smith 2015-01-16 changed ADIWG::Mdtranslator.translate() to keyword parameter list
#  Josh Bradley 2014-11-12 fix message output for plain response
#  Stan Smith 2014-11-10 remove absolute path information from error messages
#  Stan Smith 2014-11-10 return all messageObject detail when
#  ... mdTranslator returns error messages
#  Stan Smith 2014-11-10 routed empty endpoint api/v2/codelists to api/codelists
#  Stan Smith 2014-10-09 version 1 ready
#  Stan Smith 2014-10-09 implemented changes suggested by Will Fisher, UAF
# 	Stan Smith 2014-09-05 migration to Rails 4.1.1 for implementation
#  Josh Bradley 2013-12-28 implementation of demo website
# 	Stan Smith 2013-08-09 proof of concept

class Api::V2::TranslatorsController < ApplicationController

   # Gets
   # not supported

   # POSTs
   # ...api/v2/translator
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
      # ...native output of writer - @mdReturn[:writerOutputFormat]
      # ...success or failure of mdTranslator validation of input

      # construct a hash to collect response content
      @responseInfo = {}
      @responseInfo[:readerPass] = false
      @responseInfo[:writerPass] = false
      @responseInfo[:success] = false
      @responseInfo[:messages] = {}
      @responseInfo[:data] = nil

      # load any output returned from mdTranslator into the response hash
      @responseInfo[:data] = @mdReturn[:writerOutput]

      # check for errors returned by parser, validator, reader, and writer
      # separate reader and writer errors
      if @mdReturn[:readerStructurePass] && @mdReturn[:readerValidationPass] && @mdReturn[:readerExecutionPass]
         @responseInfo[:readerPass] = true
      end
      @responseInfo[:writerPass] = @mdReturn[:writerPass]
      @responseInfo[:success] = true if @responseInfo[:readerPass] && @responseInfo[:writerPass]

      # errors messages were returned by mdTranslator's parser, validator, reader, or writer modules
      if @responseInfo[:success] == false

         # pass all information received from the mdTranslator to the requester
         # ... to assist in error resolution
         # ... remove absolute paths from validation messages
         @responseInfo[:messages] = @mdReturn

         # handling validator messages
         if !@mdReturn[:readerValidationPass]
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
         end

      end

      case format
         when 'auto'
            if @responseInfo[:success]
               # there were no validation errors
               case @mdReturn[:writerOutputFormat]
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

                  when 'html'
                     if params[:callback] == ''
                        render inline: @mdReturn[:writerOutput]
                     else
                        render json: @mdReturn[:writerOutput], callback: params[:callback]
                     end

                  when nil
                     # be sure writerOutputFormat was returned nil because no writer was requested
                     if writerName == ''
                        if params[:callback] == ''
                           render plain: 'Success'
                        else
                           render json: 'Success', callback: params[:callback]
                        end
                     else
                        s = ''
                        s += "Warning - No validation errors were detected, but writer did not return success\n"
                        s += "Be sure writer name is correct\n"
                        s += "Check for writer specific error messages\n"
                        if params[:callback] == ''
                           render plain: s
                        else
                           render json: s, callback: params[:callback]
                        end
                     end

                  else
                     render plain: 'Response format ' + @mdReturn[:writerOutputFormat] + ' not handled.'

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