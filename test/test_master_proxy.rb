#!/usr/bin/env ruby

require 'ros/master_proxy'
require 'test/unit'

class TestRegister < Test::Unit::TestCase
  DUMMY_SERVICE_URI = 'rosrpc://dummy:1234'
  DUMMY_SERVICE_NAME = '/dummy_service'

  DUMMY_TOPIC_NAME = '/dummy_service'

  def test_service
    proxy = ROS::MasterProxy.new('/test_node', ENV['ROS_MASTER_URI'], 'http://dummy:11111')
    proxy.register_service(DUMMY_SERVICE_NAME, DUMMY_SERVICE_URI)
    uri = proxy.lookup_service(DUMMY_SERVICE_NAME)
    assert_equal(DUMMY_SERVICE_URI, uri)
    proxy.unregister_service(DUMMY_SERVICE_NAME, DUMMY_SERVICE_URI)
    result = proxy.lookup_service(DUMMY_SERVICE_NAME)
    assert(!result)
  end

  def test_subscriber
    proxy = ROS::MasterProxy.new('/test_node2', ENV['ROS_MASTER_URI'], 'http://dummy:11112')
    pub = proxy.register_subscriber('/rosout_agg', 'rosgraph_msgs/Log')
    assert(pub.length > 0)
    proxy.unregister_subscriber('/rosout_agg')
  end

  def test_publisher
    proxy = ROS::MasterProxy.new('/test_node3', ENV['ROS_MASTER_URI'], 'http://dummy:11113')
    sub = proxy.register_publisher('/rosout', 'rosgraph_msgs/Log')
    assert(sub.length > 0)
    num = proxy.unregister_publisher('/rosout')
    assert_equal(1, num)
  end

  def test_param_subscriber
    proxy = ROS::MasterProxy.new('/test_node4', ENV['ROS_MASTER_URI'], 'http://dummy:11114')
    assert(proxy.subscribe_param('/rosversion'))
    assert(proxy.unsubscribe_param('/rosversion'))
  end
end


class TestSystem < Test::Unit::TestCase

  def test_lookup
    proxy = ROS::MasterProxy.new('/test_node', ENV['ROS_MASTER_URI'], 'http://dummy:11111')
    uri = proxy.lookup_node('/rosout')
    assert(/^http:.*:[0-9]+/ =~ uri)
    assert(!proxy.lookup_node('/THIS_NODE_DOES_NOT_EXIST'))
    assert(proxy.get_published_topics('').length > 0)
    assert(proxy.get_published_topics('/NO_EXIST_NS').length == 0)
    pub, sub, ser = proxy.get_system_state
    assert_equal(1, pub.length)
    assert_equal(1, sub.length)
    # assert_equal(2, ser.length) # ruby logger has no service
    assert(proxy.get_uri.scan(/^#{ENV['ROS_MASTER_URI']}/))
  end

  def test_accessor
    proxy = ROS::MasterProxy.new('/test_node', ENV['ROS_MASTER_URI'], 'http://dummy:11111')
    assert_equal(ENV['ROS_MASTER_URI'], proxy.master_uri)
    assert_equal('http://dummy:11111', proxy.slave_uri)
    proxy.slave_uri = 'http://dummy2:12345'
    assert_equal('http://dummy2:12345', proxy.slave_uri)
    proxy.master_uri = 'http://fail'
    assert_equal('/test_node', proxy.caller_id)
    proxy.caller_id = '/changed'
    assert_equal('/changed', proxy.caller_id)
    assert_raise(SocketError) {proxy.get_uri}
  end
end
