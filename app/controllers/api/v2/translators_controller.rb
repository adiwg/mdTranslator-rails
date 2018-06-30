# Alaska Data Integration working group - ADIwg
# development team:
# 	U.S. Geological Survey - Alaska Science Center
#	U.S. Fish & Wildlife - Arctic Landscape Conservation Cooperative
#	Axiom Alaska Consulting
#	Nunatec Consulting

# REST endpoint controller for ruby gem adiwg-mdtranslator

# History:
#  Stan Smith 2018-05-07 return all parameters in formatted text for 'plain' response
#  Stan Smith 2018-05-07 remove JSONp callback - obsolete
#  Stan Smith 2018-05-04 add 'forceValid' flag
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

require 'pp'

class Api::V2::TranslatorsController < ApplicationController
  include Util
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
      showAllTags = true if params[:showAllTags] == 'true'
      forceValid = true
      forceValid = false if params[:forceValid] == 'false'
      requestFormat = 'auto'
      requestFormat = params[:format] if params[:format]

      # call the ADIwg metadata translator
      @mdReturn = ADIWG::Mdtranslator.translate(
         file: fileObj, reader: readerName, validate: validation,
         writer: writerName, showAllTags: showAllTags, forceValid: forceValid)

      # return content based on:
      # ... response type 'auto' w/o errors - return output in native format
      # ... response type 'auto' w/ errors - return full object in native format
      # ... response type 'xml' - always return full object in XML format
      # ... response type 'json' - always return full object in JSON format

      # construct a hash to collect response content
      @responseInfo = {}
      @responseInfo[:success] = true
      @responseInfo[:readerStructureStatus] = 'OK'
      @responseInfo[:readerStructureMessages] = @mdReturn[:readerStructureMessages]
      @responseInfo[:readerValidationStatus] = 'OK'
      @responseInfo[:readerValidationMessages] = @mdReturn[:readerValidationMessages]
      @responseInfo[:readerExecutionStatus] = 'OK'
      @responseInfo[:readerExecutionMessages] = @mdReturn[:readerExecutionMessages]
      @responseInfo[:writerStatus] = 'OK'
      @responseInfo[:writerMessages] = @mdReturn[:writerMessages]
      @responseInfo[:readerRequested] = @mdReturn[:readerRequested]
      @responseInfo[:readerVersionRequested] = @mdReturn[:readerVersionRequested]
      @responseInfo[:readerVersionUsed] = @mdReturn[:readerVersionUsed]
      @responseInfo[:writerRequested] = @mdReturn[:writerRequested]
      @responseInfo[:writerVersion] = @mdReturn[:writerVersion]
      @responseInfo[:writerOutputFormat] = @mdReturn[:writerOutputFormat]
      @responseInfo[:writerForceValid] = @mdReturn[:writerForceValid]
      @responseInfo[:writerShowTags] = @mdReturn[:writerShowTags]
      @responseInfo[:writerCSSlink] = @mdReturn[:writerCSSlink]
      @responseInfo[:writerMissingIdCount] = @mdReturn[:writerMissingIdCount]
      @responseInfo[:translatorVersion] = @mdReturn[:translatorVersion]
      @responseInfo[:writerOutput] = @mdReturn[:writerOutput]

      # set messages Status (ERROR, WARNING, NOTICE, none)
      aSMess = @responseInfo[:readerStructureMessages]
      aVMess = @responseInfo[:readerValidationMessages]
      aEMess = @responseInfo[:readerExecutionMessages]
      aWMess = @responseInfo[:writerMessages]

      status = 'OK'
      status = 'NOTICE' if aSMess.any? {|s| s.include?('NOTICE')}
      status = 'WARNING' if aSMess.any? {|s| s.include?('WARNING')}
      status = 'ERROR' if aSMess.any? {|s| s.include?('ERROR')}
      @responseInfo[:readerStructureStatus] = status

      status = 'OK'
      status = 'NOTICE' if aVMess.any? {|s| s.include?('NOTICE')}
      status = 'WARNING' if aVMess.any? {|s| s.include?('WARNING')}
      status = 'ERROR' if aVMess.any? {|s| s.include?('ERROR')}
      @responseInfo[:readerValidationStatus] = status

      status = 'OK'
      status = 'NOTICE' if aEMess.any? {|s| s.include?('NOTICE')}
      status = 'WARNING' if aEMess.any? {|s| s.include?('WARNING')}
      status = 'ERROR' if aEMess.any? {|s| s.include?('ERROR')}
      @responseInfo[:readerExecutionStatus] = status

      status = 'OK'
      status = 'NOTICE' if aWMess.any? {|s| s.include?('NOTICE')}
      status = 'WARNING' if aWMess.any? {|s| s.include?('WARNING')}
      status = 'ERROR' if aWMess.any? {|s| s.include?('ERROR')}
      @responseInfo[:writerStatus] = status

      # check for errors returned by parser, validator, reader, and writer
      @responseInfo[:success] = false unless @mdReturn[:readerStructurePass]
      @responseInfo[:success] = false unless @mdReturn[:readerValidationPass]
      @responseInfo[:success] = false unless @mdReturn[:readerExecutionPass]
      @responseInfo[:success] = false unless @mdReturn[:writerPass]

      # the json schema validator returns expanded folder/file path names to gem
      # these path names may pose a security risk and are removed from the messages
      # find gem path and removed it from messages
      unless @responseInfo[:readerValidationStatus] == 'OK'
         each_recur(@responseInfo[:readerValidationMessages]) do |elem, idx, arr|
           arr[idx]=sanitize(elem)
         end
      end


      # NOTE: to format for expected v2 response
      responseV2 = {
        success: @responseInfo[:success],
        messages: {
          :readerRequested => @responseInfo[:readerRequested],
          :readerVersionRequested => @responseInfo[:readerVersionRequested],
          :readerVersionUsed =>@responseInfo[:readerVersionUsed],
          :readerStructurePass =>@responseInfo[:readerStructureStatus] != 'ERROR',
          :readerStructureMessages =>@responseInfo[:readerStructureMessages],
          :readerValidationLevel =>@responseInfo[:readerValidationLevel],
          :readerValidationPass =>@responseInfo[:readerValidationStatus] != 'ERROR',
          :readerValidationMessages =>@responseInfo[:readerValidationMessages],
          readerExecutionPass: @responseInfo[:readerExecutionStatus]  != 'ERROR',
          readerExecutionMessages: @responseInfo[:readerExecutionMessages],
          writerRequested: @responseInfo[:writerRequested],
          writerVersion: @responseInfo[:writerVersion],
          writerPass: @responseInfo[:writerStatus] != 'ERROR',
          writerMessages: @responseInfo[:writerMessages],
          writerOutputFormat: @responseInfo[:writerOutputFormat],
          writerOutput: @responseInfo[:writerOutput],
          writerForceValid: @responseInfo[:writerForceValid],
          writerShowTags: @responseInfo[:writerShowTags],
          writerCSSlink: @responseInfo[:writerCSSlink],
          writerMissingIdCount: @responseInfo[:writerMissingIdCount],
          translatorVersion: @responseInfo[:translatorVersion] },
        data: @responseInfo[:writerOutput] }


      # build lightly formatted string for 'plain' text rendering
      sPlain = format_plain(responseV2).sub("messages:\n",'')

      #leave messages but don't replicate writerOutput
      responseV2[:messages].delete(:writerOutput)

      if requestFormat == 'auto'
         if @responseInfo[:success]
            render xml: @responseInfo[:writerOutput] if @responseInfo[:writerOutputFormat] == 'xml'
            render json: @responseInfo[:writerOutput] if @responseInfo[:writerOutputFormat] == 'json'
            render inline: @responseInfo[:writerOutput] if @responseInfo[:writerOutputFormat] == 'html'
            unless %w(xml json html).include?(@responseInfo[:writerOutputFormat])
               if writerName == ''
                  render plain: sPlain
               else
                  render plain: 'Requested format ' + @responseInfo[:writerOutputFormat] + ' not handled.'
               end
            end
         else
            render plain: sPlain
         end
      end

      render plain: sPlain if requestFormat == 'plain'
      render json: responseV2 if requestFormat == 'json'
      render xml: responseV2 if requestFormat == 'xml'
   end

   alias_method :show, :create
end
