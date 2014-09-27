# Alaska Data Integration working group (ADIwg)
# ISO 19115/19110 translator project
# Author: Stan Smith - USGS
# Author: Josh Bradley - USFWS

# Return message content in xml wrapper

# History:
# 	Stan Smith 2014-08-24 original script

xml.instruct!
xml.comment!('ADIwg mdTranslator response')
xml.response do
	xml.success @responseInfo[:success]
	xml.messages do
		@responseInfo[:messages].each do |message|
			xml.message message
		end
	end
	xml.data @responseInfo[:data]
end

