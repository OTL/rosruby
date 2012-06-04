#!/usr/bin/env ruby

require 'test/unit'
require 'ros/package'

class TestPackage < Test::Unit::TestCase
  def test_pack
    ROS::Package.read_cache_or_find_all
  end
end
