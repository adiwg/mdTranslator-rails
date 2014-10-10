# Alaska Data Integration working group - ADIwg

# REST endpoint controller for description of api

# History:
# 	Stan Smith 2014-10-09 initial

class Option
	def self.getOptionList
		hOptions = {
			readers: %w[adiwgJson],
			writers: %w[iso19115_2],
			formats: %w[auto plain json xml],
			validators: %w[none normal strict]
		}
	end
end
