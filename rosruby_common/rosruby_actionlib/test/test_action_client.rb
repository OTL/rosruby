#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_actionlib")
require 'test/unit'
require 'actionlib/action_client'
require 'actionlib_tutorials/FibonacciAction'

class TestActionClient < Test::Unit::TestCase
  def test_hoge
    node = ROS::Node.new('test_action_client')
    client = Actionlib::Client.new(node, '/fibonacci', Actionlib_tutorials::FibonacciAction)
    goal = Actionlib_tutorials::FibonacciGoal.new
    goal.order = 5
    sleep 1
    if client.wait_for_server
      client.send_goal(goal)
      p client.wait_for_result(20.0).sequence
    end
  end
end
