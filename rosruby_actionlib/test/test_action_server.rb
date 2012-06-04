#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_actionlib")
require 'test/unit'
require 'actionlib/action_server'
require 'actionlib_tutorials/FibonacciAction'

class TestActionServer < Test::Unit::TestCase
  def test_success_pubsub
    node = ROS::Node.new('/test_action_server')
    server = Actionlib::ActionServer.new(node,
					 '/fibonacci',
					 Actionlib_tutorials::FibonacciAction)
    @order = nil
    server.start do |goal, handle|
      @order = goal.order
      result = Actionlib_tutorials::FibonacciResult.new
      result.sequence = [0, 1, 2]
      handle.set_succeeded(result)
    end

    node2 = ROS::Node.new('/test_xx')
    goal_publisher = node2.advertise('/fibonacci/goal',
				     Actionlib_tutorials::FibonacciActionGoal)
    @result = nil
    @id = nil
    node2.subscribe('/fibonacci/result',
		    Actionlib_tutorials::FibonacciActionResult) do |msg|
      @id = msg.status.goal_id.id
      @result = msg.result
    end
    @status_come = nil
    node2.subscribe('/fibonacci/status',
		    Actionlib_msgs::GoalStatusArray) do |msg|
      @status_come = msg
    end

    sleep 2

    goal = Actionlib_tutorials::FibonacciActionGoal.new
    goal.goal_id.id = '/test_id'

    goal.goal.order = 2
    goal_publisher.publish(goal)

    begin
      timeout(3.0) do
	while not @order or not @result
	  sleep 0.5
	  node.spin_once
	  node2.spin_once
	end
      end
    rescue Timeout::Error
      assert(nil, 'timeouted')
    end

    assert_equal(2, @order)
    assert(@result)

    assert_equal([0, 1, 2], @result.sequence)
    assert_equal('/test_id', @id)
    assert(@status_come)

    server.shutdown
    node.shutdown
    node2.shutdown
  end
end
