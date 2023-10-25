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
         writer: %w[html simple_html fgdc iso19115_3 iso19115_2 iso19115_1 iso19110 mdJson sbJson],
         format: %w[auto plain json xml],
         validate: %w[none normal strict],
         showAllTags: %w[true false],
         forceValid: %w[true false]
      }
   end
end
