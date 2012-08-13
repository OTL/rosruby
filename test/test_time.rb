#!/usr/bin/env ruby

require 'test/unit'
require 'ros'

class TestTime < Test::Unit::TestCase
  def test_time
    param = ROS::ParameterManager.new(ENV['ROS_MASTER_URI'], '/use_sim_time', {})
    param.set_param('/use_sim_time', false)
    assert(!param.get_param('/use_sim_time'))

    t1 = ROS::Time.new
    assert_equal(0, t1.secs)
    assert_equal(0, t1.nsecs)

    t2 = ROS::Time.now
    d0 = ROS::Duration.new(1.0)
    d0.sleep
    t3 = ROS::Time.now
    assert_in_delta(1.0, (t3 - t2).to_sec, 0.1)
    assert(t3 > t2)

    d1 = ROS::Duration.new(1.0)
    assert_equal(1, d1.secs)
    assert_equal(0, d1.nsecs)

    d2 = ROS::Duration.new(1.1)
    assert_equal(1, d2.secs)
    assert_equal(100000000, d2.nsecs)

    d3 = d1 + d2
    assert_equal(2, d3.secs)
    assert_equal(100000000, d3.nsecs)

    d4 = d2 - d1
    assert_equal(0, d4.secs)
    assert_equal(100000000, d4.nsecs)
    assert(d2 > d1)
    assert(d1 < d2)

  end

  def test_to_time
    t1 = ROS::Time.new
    assert_equal(::Time, t1.to_time.class)
  end

end
