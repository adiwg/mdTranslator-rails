# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
#  Stan Smith 2017-05-20 added writer mdJson
#  Stan Smith 2014-12-04 added iso19110 writer
# 	Stan Smith 2014-10-09 initial

class Option
   def self.getOptionList
      hOptions = {
         readers: %w[mdJson],
         writers: %w[iso19115_2 iso19110 html mdJson],
         formats: %w[auto plain json xml],
         validators: %w[none normal strict]
      }
   end
end
