#!/usr/bin/env ruby

require 'ros'
require 'test/unit'

class TestLog < Test::Unit::TestCase
  def test_output
    node1 = ROS::Node.new('/test_log')
    check_msg = nil
    sub = node1.subscribe('/rosout', Rosgraph_msgs::Log) do |msg|
      check_msg = msg
    end
    node1.loginfo('msg1')
    sleep(0.5)
    node1.spin_once
    assert_equal('msg1', check_msg.msg)
    assert_equal(Rosgraph_msgs::Log::INFO, check_msg.level)

    node1.logerror('msg2')
    sleep(0.1)
    node1.spin_once
    assert_equal('msg2', check_msg.msg)
    assert_equal(Rosgraph_msgs::Log::ERROR, check_msg.level)

    node1.logfatal('msg3')
    sleep(0.1)
    node1.spin_once
    assert_equal('msg3', check_msg.msg)
    assert_equal(Rosgraph_msgs::Log::FATAL, check_msg.level)

    node1.logfatal('msg4')
    sleep(0.1)
    node1.spin_once
    assert_equal('msg4', check_msg.msg)
    assert_equal(Rosgraph_msgs::Log::FATAL, check_msg.level)

    node1.logwarn('msg5')
    sleep(0.1)
    node1.spin_once
    assert_equal('msg5', check_msg.msg)
    assert_equal(Rosgraph_msgs::Log::WARN, check_msg.level)

    node1.shutdown
  end
end
