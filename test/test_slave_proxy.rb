#!/usr/bin/env ruby

require 'ros'
require 'test/unit'
require 'std_msgs/String'

class TestSlaveProxy < Test::Unit::TestCase
  TEST_STRING1 = 'TEST1'
  TEST_STRING2 = 'TEST2'

  def test_slave1
    node = ROS::Node.new('/test_slave1')
    pub1 = node.advertise('/chatter', Std_msgs::String)

    pub_msg1 = Std_msgs::String.new
    pub_msg1.data = TEST_STRING1

    message_has_come1 = nil

    sub1 = node.subscribe('/chatter', Std_msgs::String) do |msg|
      if msg.data == TEST_STRING1
        message_has_come1 = true
      end
    end

    # wait for registration and update
    while sub1.get_number_of_publishers < 1
      sleep 0.1
    end

    pub1.publish(pub_msg1)

    while not node.spin_once
      sleep 0.1
    end

    sub1.get_connection_info
    slave_uri = sub1.get_connection_info[0][1]
    slave = ROS::SlaveProxy.new('/slave1', slave_uri)

    assert(slave.get_bus_stats)
    assert(slave.get_bus_info)

    assert(/^http:.+:[0-9]+/ =~ slave.get_master_uri)
    assert(/[0-9]+/ =~ slave.get_pid.to_s)
    assert_equal([["/chatter", "std_msgs/String"]], slave.get_subscriptions)
    assert_equal(2, slave.get_publications.size)
    assert(slave.param_update('/hoge', 1))
    assert(slave.publisher_update('/hoge', ['http://aaa:111']))
    assert_equal(3, slave.request_topic('/chatter', [["TCPROS"]]).size)

    assert(slave.shutdown('test kill'))
    node.shutdown
  end
end
