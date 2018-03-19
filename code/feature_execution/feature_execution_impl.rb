require 'singleton'

 # classes = []

def adapt_classes(klass)

end

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }


def proceed
  # puts "self == #{self}"
  self.text
end

class FeatureExecutionImpl

  attr_reader :memory, :last_feature

  def initialize
    @memory = Hash.new
    @last_feature = nil
  end


	include Singleton

	def alter(action, feature_selector)
		if action == :adapt
			adapt(feature_selector)
    elsif action == :unadapt
      unadapt(feature_selector)
		end
		# TODO To be completed
	end

  # TODO To be completed if needed
	def adapt(feature_selector)
		# puts "cpt = #{@cpt}"
    module_obj = Object.const_get(feature_selector.feature)
		class_obj = Object.const_get(feature_selector.klass)
		methods_names_array = module_obj.instance_methods

    # check if the klass has been saved
    unless @memory.key(feature_selector.klass)
      # puts "create #{feature_selector.klass}"
      @memory[feature_selector.klass] = Hash.new
    end

    # foreach methods in the module
		methods_names_array.each do |method_item|

      begin
        old_method = class_obj.instance_method(method_item)
      rescue
        old_method = nil
      end

      # check if the method already exist ?
      unless old_method.nil?
        # check if the method has been already saved before ?
        unless @memory[feature_selector.klass][method_item]
          # puts "create #{method_item}"
          @memory[feature_selector.klass][method_item] = []
        end
        # save the old method
        @memory[feature_selector.klass][method_item].push({"#{@last_feature}" => old_method})
      end
			method_obj = module_obj.instance_method(method_item)
			class_obj.send(:define_method, method_item, method_obj)
    end
    @last_feature = feature_selector.feature
  end

  def unadapt(feature_selector)
    module_obj = Object.const_get(feature_selector.feature)
    class_obj = Object.const_get(feature_selector.klass)

    methods_names_array = module_obj.instance_methods

    # foreach methods of the module
    methods_names_array.each do |method_item|

      method_obj = module_obj.instance_method(method_item)

      if @last_feature == feature_selector.feature

        class_obj.send(:remove_method, method_item)

        if @memory[feature_selector.klass] && @memory[feature_selector.klass][method_item]
          method_old = @memory[feature_selector.klass][method_item].pop()
          if method_old
            method_old.each do |key, value|
              class_obj.send(:define_method, method_item, value)
              @last_feature = key
            end
          end
        end
      end




    end
  end
end
