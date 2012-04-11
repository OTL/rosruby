#!/usr/bin/ruby

require 'ros/rate'
require 'test/unit'

class TestRate_rate < Test::Unit::TestCase
  def test1
    r = ROS::Rate.new(10)
    start = Time.now
    (1..10).each do |i|
      puts "this is #{i}"
      r.sleep
    end
    stop = Time.now
    assert_in_delta(1.0, (stop - start), 0.1)
  end
end
