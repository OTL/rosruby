#!/usr/bin/env ruby

require 'ros'
require 'test/unit'
require 'std_msgs/String'

class TestPubSubNormal < Test::Unit::TestCase
  TEST_STRING1 = 'TEST1'
  TEST_STRING2 = 'TEST2'

  def test_double_pubsub
    node1 = ROS::Node.new('/test_pubsub1')
    node2 = ROS::Node.new('/test_pubsub2')
    pub1 = node1.advertise('/chatter', Std_msgs::String)
    assert_equal(0, pub1.get_number_of_subscribers)

    pub2 = node2.advertise('/chatter', Std_msgs::String)
    assert_equal(0, pub2.get_number_of_subscribers)

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

    while sub1.get_number_of_publishers < 2
      sleep 0.1
    end
    while sub2.get_number_of_publishers < 2
      sleep 0.1
    end

    assert_equal(2, sub1.get_number_of_publishers)
    assert_equal(2, sub2.get_number_of_publishers)
    assert_equal(2, pub1.get_number_of_subscribers)
    assert_equal(2, pub2.get_number_of_subscribers)

    pub1.publish(pub_msg1)
    pub2.publish(pub_msg2)

    sleep 0.1

    while not node1.spin_once
      sleep 0.1
    end

    while not node2.spin_once
      sleep 0.1
    end

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

  def test_single_pubsub
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

    while sub1.get_number_of_publishers < 1
      sleep 0.1
    end

    pub1.publish(pub_msg1)

    sleep(0.1)

    while not node.spin_once
      sleep 0.1
    end

    assert(message_has_come1)

    assert_equal([["/chatter_out_0", 13, 1, 1]], pub1.get_connection_data)
    assert_equal([["/chatter_in_0", 9, 1]], sub1.get_connection_data)

    pub_info = pub1.get_connection_info[0]
    assert_equal("/chatter_out_0", pub_info[0])
    # incomplete
#    assert(/^http:.*:[0-9]+/=~, pub_info[1])
    assert_equal("o", pub_info[2])
    assert_equal("TCPROS", pub_info[3])
    assert_equal("/chatter", pub_info[4])

    sub_info = sub1.get_connection_info[0]
    assert_equal("/chatter_in_0", sub_info[0])
    assert(/^http:.*[0-9]+/=~ sub_info[1])
    assert_equal("i", sub_info[2])
    assert_equal("TCPROS", sub_info[3])
    assert_equal("/chatter", sub_info[4])

    node.shutdown
  end

  def test_single_subpub
    # subscribe -> advertise
    node = ROS::Node.new('/test6')
    message_has_come1 = nil

    sub1 = node.subscribe('/chatter', Std_msgs::String) do |msg|
      if msg.data == TEST_STRING1
        message_has_come1 = true
      end
    end

    pub1 = node.advertise('/chatter', Std_msgs::String)

    while sub1.get_number_of_publishers < 1
      sleep 0.1
    end

    pub_msg1 = Std_msgs::String.new
    pub_msg1.data = TEST_STRING1

    pub1.publish(pub_msg1)
    sleep 0.1

    while not node.spin_once
      pub1.publish(pub_msg1)
      sleep 0.1
    end

    assert(message_has_come1)
    node.shutdown
  end

  def test_shutdown_by_publisher_or_subscriber_directly
    node = ROS::Node.new('/test4')
    pub = node.advertise('/hoge', Std_msgs::String)
    proxy = ROS::MasterProxy.new('/test_node', ENV['ROS_MASTER_URI'], 'http://dummy:11111')
    assert(proxy.get_published_topics.include?(["/hoge", "std_msgs/String"]))
    pub.shutdown
    assert(!proxy.get_published_topics.include?(["/hoge", "std_msgs/String"]))

    sub1 = node.subscribe('/hoge', Std_msgs::String)
    pub, sub, ser = proxy.get_system_state
    assert(sub.include?(["/hoge", ["/test4"]]))
    sub1.shutdown
    pub, sub, ser = proxy.get_system_state
    assert(!sub.include?(["/hoge", ["/test4"]]))

    node.shutdown
  end


  def test_latched
    node = ROS::Node.new('/test5')
    pub1 = node.advertise('/chatter', Std_msgs::String, :latched=>true)

    pub_msg1 = Std_msgs::String.new
    pub_msg1.data = TEST_STRING1

    pub1.publish(pub_msg1)

    message_has_come1 = nil

    sub1 = node.subscribe('/chatter', Std_msgs::String) do |msg|
      if msg.data == TEST_STRING1
        message_has_come1 = true
      end
    end

    while sub1.get_number_of_publishers < 1
      sleep 0.1
    end

    while not node.spin_once
      sleep 0.1
    end

    assert(message_has_come1)
    node.shutdown
  end
end
