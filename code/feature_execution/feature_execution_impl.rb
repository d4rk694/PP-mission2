require 'singleton'

def adapt_classes klass
  # puts klass
  klass
end

def proceed

  # variable
  meth = caller.first[/`(.*)'/, 1]
  klass = self.class.name

  string = "#{caller.first[/.+\/(.+).rb/]}"
  mod = string.match(/.+\/(.+).rb/).captures # the module name is at mod.first
  mod = mod.first
  mod[0] = mod[0].upcase

  #puts "proceed => mod: #{mod}, class : #{klass}, meth : #{meth}"

  meth_un = recover_meth_from_memory(mod, klass, meth)

  to_return = meth_un.bind(self).call()

  to_return
end

def recover_meth_from_memory(mod, klass, meth)
  memory = FeatureExecutionImpl.instance.getMemory()
  last = FeatureExecutionImpl.instance.getLastFeat()

  #puts "#{memory}"
  methods = memory[klass][meth]

  meth_un = nil
  if last[klass][meth] == mod
    meth_un = memory[klass][meth].last
  else
    index = -1
    cpt = 0
    methods.each do |method_item|
      if method_item[0] == mod
        index = cpt -1
      end
      cpt = cpt + 1
    end
    meth_un = memory[klass][meth][index]
  end

  meth_un[1]
end


Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each {|file| require file}
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each {|file| require file}

class FeatureExecutionImpl

  attr_reader :memory, :last_feature

  include Singleton

  def getMemory
    @memory
  end

  def getLastFeat
    @last_feature
  end

  def initialize
    @memory = Hash.new
    @last_feature = Hash.new
  end

  def alter(action, feature_selector)
    if action == :adapt
      adapt(feature_selector)
    elsif action == :unadapt
      unadapt(feature_selector)
    end
  end

  def adapt(feature_selector)
    # puts "adapt : #{feature_selector.feature}"
    # recover object for the module/class/methodes name
    module_obj = Object.const_get(feature_selector.feature)
    class_obj = Object.const_get(feature_selector.klass)
    methods_names_array = module_obj.instance_methods

    # Check if the klass has been saved
    if @memory[feature_selector.klass].nil?
      # puts "create #{feature_selector.klass}"
      @memory[feature_selector.klass] = Hash.new

      @last_feature[feature_selector.klass] = Hash.new
    end

    methods_names_array.each do |method_item|

      # test if the method exists in the class
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
        @memory[feature_selector.klass]["#{method_item}"].push(
            ["#{@last_feature[feature_selector.klass]["#{method_item}"]}", old_method]
        )
      end

      add_method_to_class(module_obj, class_obj, method_item)
      @last_feature[feature_selector.klass]["#{method_item}"] = feature_selector.feature

    end

    # puts "Last => #{@last_feature}"
    # puts "Mem => #{@memory}"

  end

  def unadapt(feature_selector)
    # puts "unadapt"
    # variables
    module_obj = Object.const_get(feature_selector.feature)
    class_obj = Object.const_get(feature_selector.klass)

    methods_names_array = module_obj.instance_methods

    methods_names_array.each do |method_item|

      if @last_feature[feature_selector.klass]["#{method_item}"] == feature_selector.feature
        # puts "pop  #{method_item} ..."
        # remove the method
        class_obj.send(:remove_method, method_item)
        unless @memory[feature_selector.klass]["#{method_item}"].nil?
          meth_un = @memory[feature_selector.klass]["#{method_item}"].pop()
          unless meth_un.nil?
            class_obj.send(:define_method, method_item, meth_un[1])
            @last_feature[feature_selector.klass]["#{method_item}"] = meth_un[0]
          end

          if @memory[feature_selector.klass]["#{method_item}"].empty?
            memory[feature_selector.klass].delete("#{method_item}")
          end
        else
          @last_feature[feature_selector.klass].delete("#{method_item}")
        end

      else
        unless @memory[feature_selector.klass]["#{method_item}"].empty?
          index = -1
          cpt = 0;
          @memory[feature_selector.klass]["#{method_item}"].each do |method_item|
            if method_item[0] == feature_selector.feature
              index = cpt
              break
            end
            cpt = cpt + 1
          end
          if index > 0
            # puts "removing #{method_item} ...  at index #{index}"
            @memory[feature_selector.klass]["#{method_item}"].delete_at(index)
          end
          puts index
        end
      end


    end


    # puts "Last => #{@last_feature}"
    # puts "Mem => #{@memory}"
  end

  ######################################################################
  ############################## UTILS #################################
  ######################################################################

  def add_method_to_class(module_obj, class_obj, method_item)

    method_obj = module_obj.instance_method(method_item)
    # puts "methObj => #{method_obj}"
    class_obj.send(:define_method, method_item, method_obj)
    # puts "ClassObj => #{class_obj}"
  end

  def remove_method_from_class(module_obj, class_obj)
    methods_names_array = module_obj.instance_methods

    methods_names_array.each do |method_item|
      # remove the method
      class_obj.send(:remove_method, method_item)
    end

  end

  # TODO To be completed if needed

end