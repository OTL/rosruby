#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_actionlib")
require 'test/unit'
require 'actionlib/simple_action_server'
require 'actionlib_tutorials/FibonacciAction'

class TestActionServer < Test::Unit::TestCase
  def test_hoge
    node = ROS::Node.new('/test_action_server')
    server = Actionlib::SimpleActionServer.new(node, '/fibonacci', Actionlib_tutorials::FibonacciAction)
    server.start do |goal|
      p 'goal has come'
      p goal.order
      result = Actionlib_tutorials::FibonacciResult.new
      result.sequence = [1]
      server.set_succeeded(result)
    end
    node.spin
  end
end
