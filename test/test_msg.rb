#!/usr/bin/env ruby

require 'ros'
require 'rosgraph_msgs/Log'
require 'std_msgs/UInt8MultiArray'
require 'test/unit'

class TestMessageInitialization < Test::Unit::TestCase
  def test_message
    now = ROS::Time.now
    log = Rosgraph_msgs::Log.new(:header => Std_msgs::Header.new(:seq => 1,
                                                                 :stamp => now,
                                                                 :frame_id => 'aa'),
                                 :level => Rosgraph_msgs::Log::DEBUG,
                                 :topics => ["/a", "/b"])
    assert_equal(1, log.header.seq)
    assert_equal(now, log.header.stamp)
    assert_equal('aa', log.header.frame_id)
    assert_equal(Rosgraph_msgs::Log::DEBUG, log.level)
    assert_equal(["/a", "/b"], log.topics)
    assert_equal("", log.name)
    assert_equal("", log.function)

  end

  def test_message_invalid
    now = ROS::Time.now
    log = Rosgraph_msgs::Log.new(:aaa => '',
                                 :bbbb => '')
    assert_equal(0, log.level)
    assert_equal("", log.name)
    assert_equal("", log.function)
  end
end
