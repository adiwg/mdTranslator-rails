# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
#  Stan Smith 2018-05-31 revise option lists
#  Stan Smith 2017-05-20 added writer mdJson
#  Stan Smith 2014-12-04 added iso19110 writer
# 	Stan Smith 2014-10-09 initial

class Option
   def self.getOptionList
      {
         reader: %w[mdJson sbJson fgdc],
         writer: %w[iso19115_2 iso19110 html mdJson sbJson fgdc dcat_us],
         format: %w[auto plain json xml],
         validate: %w[none normal strict],
         showAllTags: %w[true false],
         forceValid: %w[true false]
      }
   end
end
