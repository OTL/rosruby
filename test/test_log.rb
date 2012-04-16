#!/usr/bin/env ruby

require 'ros'
require 'test/unit'

class TestLog < Test::Unit::TestCase
  def test_output
    node1 = ROS::Node.new('/test_log')
    check_msg = nil
    sub = node1.subscribe('/rosout', Rosgraph_msgs::Log) do |msg|
      puts msg
      check_msg = msg
    end
    node1.loginfo('msg1')
    sleep(0.5)
    node1.spin_once
    assert('msg1', check_msg.msg)
    assert('INFO', check_msg.level)

    node1.logerror('msg2')
    node1.spin_once
    assert('msg2', check_msg.msg)
    assert('ERROR', check_msg.level)

    node1.logfatal('msg3')
    node1.spin_once
    assert('msg3', check_msg.msg)
    assert('FATAL', check_msg.level)

    node1.logfatal('msg4')
    node1.spin_once
    assert('msg4', check_msg.msg)
    assert('DEUBG', check_msg.level)

    node1.logwarn('msg5')
    node1.spin_once
    assert('msg5', check_msg.msg)
    assert('WARN', check_msg.level)

    node1.shutdown
  end
end
