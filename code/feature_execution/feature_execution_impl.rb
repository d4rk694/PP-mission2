require 'singleton'

# classes = []

def adapt_classes(klass)

end

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each {|file| require file}
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each {|file| require file}


def proceed
  puts "memory == #{FeatureExecutionImpl.instance.memory}"
  puts
  FeatureExecutionImpl.instance.next_op(self, caller_locations(1,1)[0].label)
end



class FeatureExecutionImpl

  include Singleton

  attr_reader :memory, :last_feature, :stack_op

  def initialize
    @memory = Hash.new
    @last_feature = Hash.new
    @stack_op = Array.new
  end

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
    unless @memory[feature_selector.klass]
      puts "\tCreate new hash for #{feature_selector.klass}"
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
        unless @memory[feature_selector.klass]["#{method_item}"]
          # puts "create #{method_item}"
          @memory[feature_selector.klass]["#{method_item}"] = []
        end
        # save the old method
        @memory[feature_selector.klass]["#{method_item}"].push({"#{@last_feature[feature_selector.klass]}" => old_method})
      end
      method_obj = module_obj.instance_method(method_item)
      class_obj.send(:define_method, method_item, method_obj)
    end

    @last_feature[feature_selector.klass] = feature_selector.feature

    puts "Alter => #{@memory}"
  end

  def unadapt(feature_selector)
    module_obj = Object.const_get(feature_selector.feature)
    class_obj = Object.const_get(feature_selector.klass)

    methods_names_array = module_obj.instance_methods

    # foreach methods of the module
    methods_names_array.each do |method_item|

      method_obj = module_obj.instance_method(method_item)

      if @last_feature[feature_selector.klass] == feature_selector.feature

        class_obj.send(:remove_method, method_item)

        if @memory[feature_selector.klass] && @memory[feature_selector.klass]["#{method_item}"]
          method_old = @memory[feature_selector.klass]["#{method_item}"].pop()
          if method_old
            method_old.each do |key, value|
              class_obj.send(:define_method, method_item, value)
              @last_feature[feature_selector.klass] = key
            end
          end
        end
      end


    end
  end

  def next_op(sself, called_from)

    klass = sself.class.name
    meth = called_from
    # puts "#{klass} - #{meth}"

    unless @stack_op == nil
      @stack_op = @memory.clone
    end

    puts "stack => #{@stack_op}"
    puts "stack methods => #{@stack_op[klass][meth]}"

    meth_to_call = @stack_op[klass][meth].pop()

    if @stack_op[klass][meth].empty?
      @stack_op[klass][meth] = @memory[klass][meth].clone
    end


    puts "method => #{meth_to_call}"

    to_return = sself.text
    # #TODO change
    #
    # klass_Obj = Object.const_get(klass)
    #
    # meth_to_call.each do |key, value|
    #   klass_un = klass_Obj.instance_method(meth)
    #
    #   to_return = klass_un.bind(value).call()
    # end
    to_return
  end
end
