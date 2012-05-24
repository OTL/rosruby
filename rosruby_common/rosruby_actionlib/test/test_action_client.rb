#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_actionlib")
require 'test/unit'
require 'actionlib/action_client'
require 'actionlib_tutorials/FibonacciAction'

class TestActionClient < Test::Unit::TestCase
  def test_hoge
    node = ROS::Node.new('/test_action_client')
    client = Actionlib::ActionClient.new(node, '/fibonacci', Actionlib_tutorials::FibonacciAction)
    node2 = ROS::Node.new('/test_action_client_check')
    status_publisher = node2.advertise('/fibonacci/status', Actionlib_msgs::GoalStatusArray)
    result_publisher = node2.advertise('/fibonacci/result',
                                       Actionlib_tutorials::FibonacciActionResult)
    @goal = nil
    goal_subscriber = node2.subscribe('/fibonacci/goal',
                                      Actionlib_tutorials::FibonacciActionGoal) do |msg|
      @goal = msg
      result = Actionlib_tutorials::FibonacciActionResult.new
      result.result.sequence = [1,2,3]
      result.status.goal_id.id = msg.goal_id.id
      result_publisher.publish(result)
    end
    sleep 1

    assert(!client.wait_for_server(0.1))

    msg = Actionlib_msgs::GoalStatusArray.new
    status_publisher.publish(msg)

    assert(client.wait_for_server(1.0))

    goal = Actionlib_tutorials::FibonacciGoal.new
    goal.order = 5
    handle = client.send_goal(goal)
    sleep 1
    node.spin_once
    node2.spin_once
    assert(@goal)

    assert_not_equal("", handle.goal_id.id)
    assert(handle)
    result = handle.wait_for_result(1.0)
    assert(result)
    assert_equal([1,2,3], result.sequence)

    node.shutdown
    node2.shutdown
  end
end
