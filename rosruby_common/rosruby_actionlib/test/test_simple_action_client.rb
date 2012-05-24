#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_actionlib")
require 'test/unit'
require 'actionlib/simple_action_client'
require 'actionlib_tutorials/FibonacciAction'

class TestActionClient < Test::Unit::TestCase
  def test_hoge
    node = ROS::Node.new('test_action_client')
    client = Actionlib::SimpleActionClient.new(node, '/fibonacci',
                                               Actionlib_tutorials::FibonacciAction)
    goal = Actionlib_tutorials::FibonacciGoal.new
    goal.order = 5
    sleep 1
    if client.wait_for_server
      client.send_goal(goal)
      if result = client.wait_for_result(20.0)
        p result.sequence
      end
    end
  end
end
