# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial
#   Stan Smith 2014-12-04 added iso19110 writer

class Option
	def self.getOptionList
		hOptions = {
			readers: %w[mdJson],
			writers: %w[iso19115_2 iso19110],
			formats: %w[auto plain json xml],
			validators: %w[none normal strict]
		}
	end
end
