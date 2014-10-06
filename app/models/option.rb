

class Option
	def self.getOptionList
		s = {
			readers: %w[adiwgJson],
			writers: %w[iso19115_2],
			formats: %w[auto plain json xml],
			validators: %w[none normal strict]
		}
	end
end