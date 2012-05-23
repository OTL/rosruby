#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_actionlib")
require 'test/unit'
require 'actionlib/action_server'
require 'actionlib_tutorials/FibonacciAction'

class TestActionServer < Test::Unit::TestCase
  def test_hoge
    node = ROS::Node.new('test_action_server')
    server = Actionlib::Server.new(node, '/fibonacci', Actionlib_tutorials::FibonacciAction)
    server.start do |goal|
      p 'goal has come'
      p goal.order
    end
    node.spin
  end
end
