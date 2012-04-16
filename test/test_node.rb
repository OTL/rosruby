#!/usr/bin/env ruby

require 'ros'
require 'test/unit'

class TestNode < Test::Unit::TestCase
  def test_up_down
    node1 = ROS::Node.new('/test1')
    assert_equal('/test1', node1.node_name)
    assert(node1.ok?)
    node1.shutdown
    assert(!node1.ok?)
    node2 = ROS::Node.new('/test2')
    assert(node2.ok?)
    node2.shutdown
    assert(!node2.ok?)
  end

  def test_multi_up_down
    node1 = ROS::Node.new('/test1')
    node2 = ROS::Node.new('/test2')
    assert(node1.ok?)
    assert(node2.ok?)
    node1.shutdown
    node2.shutdown
    assert(!node1.ok?)
    assert(!node2.ok?)
  end

  def test_anonymous
    node1 = ROS::Node.new('/test1', true)
    assert_not_equal('/test1', node1.node_name)
    node2 = ROS::Node.new('/test1', true)
    assert_not_equal('/test1', node2.node_name)
    sleep(0.5)
    assert(node1.ok?)
    assert(node2.ok?)
    node1.shutdown
    node2.shutdown
    assert(!node1.ok?)
    assert(!node2.ok?)
  end

  def test_not_anonymous
    node1 = ROS::Node.new('/test1')
    node2 = ROS::Node.new('/test1')
    sleep(0.5)
    assert(!node1.ok?) # killed by master
    assert(node2.ok?)
    node2.shutdown
    assert(!node2.ok?)
  end

  def test_signal
    node1 = ROS::Node.new('/test1')
    Process.kill(:INT, Process.pid)
    assert(!node1.ok?)
  end

  def test_master_uri
    node1 = ROS::Node.new('/test1')
    assert_equal(node1.master_uri, ENV['ROS_MASTER_URI'])

    node1.shutdown
  end

  def test_set_get
    node = ROS::Node.new('hoge')
    # integer
    assert(node.set_param('/test1', 1))
    assert_equal(1, node.get_param('/test1'))
    # float
    assert(node.set_param('/test_f', 0.1))
    assert_equal(0.1, node.get_param('/test_f'))
    # list
    assert(node.set_param('/test2', [1,2,3]))
    assert_equal([1,2,3], node.get_param('/test2'))
    # string
    assert(node.set_param('/test_s', 'hoge'))
    assert_equal('hoge', node.get_param('/test_s'))

    assert(node.has_param('/test_s'))
    assert(node.delete_param('/test_s'))
    assert(!node.has_param('/test_s'))

    node.shutdown
  end

  def test_fail
    node = ROS::Node.new('hoge')
    assert(!node.get_param('/test_no_exists'))
    node.shutdown
  end

  def test_resolve_name
    node = ROS::Node.new('hoge')

    assert_equal('/aaa', node.resolve_name('aaa'))
    assert_equal('/aaa/b/c', node.resolve_name('aaa/b////c'))
    assert_equal('/hoge/private', node.resolve_name('~private'))
    node.shutdown
  end

end
