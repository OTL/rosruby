#!/usr/bin/env ruby

require 'ros/rate'
require 'test/unit'

class TestRate_rate < Test::Unit::TestCase
  def test_sleep
    r = ROS::Rate.new(10)
    (1..10).each do |i|
      start = ::Time.now
      r.sleep
      stop = ::Time.now
      assert_in_delta(0.1, (stop - start), 0.01, "rating #{i}")
    end
  end
end
