require 'singleton'

 # classes = []

def adapt_classes(klass)

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
		puts feature_selector.to_s()
		moduleObj = Object.const_get(feature_selector.feature)
		puts moduleObj
		classObj = Object.const_get(feature_selector.klass)
		puts classObj
		methodesNamesArray = moduleObj.instance_methods
		puts
		methodesNamesArray.each do |item|
			puts item
			methodeObj = moduleObj.instance_method(item)
			classObj.send(:define_method, item, methodeObj )
		end
	end
end
