#!/usr/bin/env ruby

require 'test/unit'

test_file = "test/test_*.rb"

$:.push("#{File.dirname(__FILE__)}/..")
$:.unshift(File.join(File.expand_path("."), "lib"))
$:.unshift(File.join(File.expand_path("."), "test"))

require 'rubygems'
gem 'simplecov', :require => false, :group => :test

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end

Dir.glob(test_file) do |file|
  require file.sub(/\.rb$/, '')
end
