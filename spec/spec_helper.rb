$:.unshift(File.join(File.dirname(__FILE__), ".."))

require 'rubygems'
require 'wrong'
require 'minitest/autorun'
require 'mocha'

require 'lib/poker'

require File.expand_path("../spec_utils", __FILE__)