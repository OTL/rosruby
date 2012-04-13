#!/usr/bin/env ruby

require 'ros'
require 'test/unit'
require 'std_msgs/String'

class TestPubSubNormal < Test::Unit::TestCase
  TEST_STRING1 = 'TEST1'
  TEST_STRING2 = 'TEST2'

  def test_double_pubsub
    node1 = ROS::Node.new('/test1')
    node2 = ROS::Node.new('/test2')
    pub1 = node1.advertise('/chatter', Std_msgs::String)

    pub2 = node2.advertise('/chatter', Std_msgs::String)

    pub_msg1 = Std_msgs::String.new
    pub_msg1.data = TEST_STRING1

    pub_msg2 = Std_msgs::String.new
    pub_msg2.data = TEST_STRING2

    message_has_come1 = [nil, nil]
    message_has_come2 = [nil, nil]
    
    sub1 = node1.subscribe('/chatter', Std_msgs::String) do |msg|
      if msg.data == TEST_STRING1
        message_has_come1[0] = true
      end
      if msg.data == TEST_STRING2
        message_has_come1[1] = true
      end
    end

    sub2 = node2.subscribe('/chatter', Std_msgs::String) do |msg|
      if msg.data == TEST_STRING1
        message_has_come2[0] = true
      end
      if msg.data == TEST_STRING2
        message_has_come2[1] = true
      end
    end
    sleep(1) # wait for registration and update

    pub1.publish(pub_msg1)
    pub2.publish(pub_msg2)

    sleep(1)
    node1.spin_once
    node2.spin_once

    assert(message_has_come1[0])
    assert(message_has_come1[1])
    assert(message_has_come2[0])
    assert(message_has_come2[1])

    topics = node1.get_published_topics
    assert_equal(2, topics.length)
    assert(topics.include?('/chatter'))
    assert(topics.include?('/rosout'))
    
    node1.shutdown
    node2.shutdown
  end

  def aatest_single_pubsub
    node = ROS::Node.new('/test3')
    pub1 = node.advertise('/chatter', Std_msgs::String)

    pub_msg1 = Std_msgs::String.new
    pub_msg1.data = TEST_STRING1

    message_has_come1 = nil
    
    sub1 = node.subscribe('/chatter', Std_msgs::String) do |msg|
      if msg.data == TEST_STRING1
        message_has_come1 = true
      end
    end

    
    sleep(1) # wait for registration and update

    pub1.publish(pub_msg1)
    sleep(1)
    node.spin_once
    assert(message_has_come1)
    node.shutdown
  end

end

