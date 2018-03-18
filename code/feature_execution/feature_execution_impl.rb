require 'singleton'
def adapt_classes(klass)
	puts klass
end
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl

	include Singleton

	def alter(action, feature_selector)
		if action == :adapt
			adapt(feature_selector)
		end
		# TODO To be completed
	end

	# TODO To be completed if needed
	def adapt(feature_selector)

		puts feature_selector.klass.public_methods

		puts "adapt " + feature_selector.to_s()
	end
end
