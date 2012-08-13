#!/usr/bin/env ruby

require 'ros'
require 'test/unit'

class TestRate_rate < Test::Unit::TestCase
  def test_sleep
    param = ROS::ParameterManager.new(ENV['ROS_MASTER_URI'], '/use_sim_time', {})
    param.set_param('/use_sim_time', false)
    assert(!param.get_param('/use_sim_time'))
    r = ROS::Rate.new(10)
    (1..10).each do |i|
      start = ::Time.now
      r.sleep
      stop = ::Time.now
      assert_in_delta(0.1, (stop - start), 0.05, "rating #{i}")
    end
  end
end
