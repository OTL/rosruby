#!/usr/bin/env ruby

require 'test/unit'

test_file = "test/test_*.rb"

$:.unshift(File.join(File.expand_path("."), "src"))
$:.unshift(File.join(File.expand_path("."), "test"))

Dir.glob(test_file) do |file|
  require file.sub(/\.rb$/, '')
end
