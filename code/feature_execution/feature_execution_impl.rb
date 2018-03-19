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
		module_obj = Object.const_get(feature_selector.feature)
		class_obj = Object.const_get(feature_selector.klass)
		methods_names_array = module_obj.instance_methods
		methods_names_array.each do |item|
			method_obj = module_obj.instance_method(item)
			class_obj.send(:define_method, item, method_obj )
		end
	end
end
