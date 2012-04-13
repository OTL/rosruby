#!/usr/bin/env ruby

require 'ros'
require 'test/unit'

class TestNode < Test::Unit::TestCase
  def test_up_down
    node1 = ROS::Node.new('/test1')
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

end

