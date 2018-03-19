#!/usr/bin/env ruby

#
# Script to execute the application without the feature visualizer tool
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#

require_relative 'skeleton/text.rb'
require_relative 'skeleton/printer.rb'
require_relative '../feature_execution/feature_selector'
require_relative '../feature_execution/feature_execution_impl'

FEATURES_TEXT = {
    :clean => FeatureSelector.new('Clean', 'Text'),
    :english => FeatureSelector.new('EnglishCharacters', 'Text'),
    :french => FeatureSelector.new('FrenchCharacters', 'Text'),
    :trim => FeatureSelector.new('Trim', 'Text'),
    :capitalize => FeatureSelector.new('Capitalize', 'Text'),
    :punctuation => FeatureSelector.new('Punctuation', 'Text'),
    :printing_all_chars => FeatureSelector.new('PrintingAllChars', 'Printer'),
    :printing_standard => FeatureSelector.new('PrintingStandard', 'Printer')
}

# Method to:
# 	- create an instance of the class Text
# 	- correct the text
# 	- print out the text
def correct_text(text)
  t = Text.new(text)
  Printer.instance.printing(t.correct_text)
end

FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:printing_standard])

# Simple text
puts "Simple text"
correct_text('Hello Ruby!')
puts

# Cleaning text
puts "Cleaning text"
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:clean])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:english])
puts "English language ..."
correct_text('Hello Ruby!')
correct_text('Hello Rubéy!')
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:french])
puts "French language ..."
correct_text('Bonjour Ruby!')
correct_text('Comment vas-tu Rubéy ?')
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:french])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:english])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:clean])
puts
