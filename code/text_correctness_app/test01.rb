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
# def correct_text(text)
# 	t = Text.new(text)
# 	Printer.instance.printing(t.correct_text)
# end

FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:clean])

# Simple text
puts "Simple text"
correct_text('Hello Ruby!')
puts
