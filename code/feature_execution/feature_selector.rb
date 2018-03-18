class FeatureSelector

	attr_reader :feature, :klass

	# TODO To be completed
	def initialize(feature, klass)
		@feature = feature
		@klass = klass
	end

	def to_s()
		@feature + " " + @klass
	end

end
