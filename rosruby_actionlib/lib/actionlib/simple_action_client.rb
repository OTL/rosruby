#  actionlib/simple_action_client.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'ros'

require 'actionlib/action_client'

module Actionlib

  # Simple (only one goal) Action client.
  class SimpleActionClient

    # @param [ROS::Node] node ros node to pub/sub.
    # @param [String] action_name name of the action.
    # @param [Class] spec class of action
    def initialize(node, action_name, spec)
      @client = ActionClient.new(node, action_name, spec)
      @last_goal_handle = nil
    end

    # Send a goal to action server.
    # @param [Object] goal ActionGoal object.
    # @param [Hash] options options
    # @option options [proc] :feedback_callback callback of /feedback
    # @option options [proc] :result_callback callback of /result
    # @return [ClientGoalHandle] handle of this goal.
    def send_goal(goal, options={})
      @last_goal_handle = @client.send_goal(goal, options)
    end

    # Cancel all goals
    def cancel_all_goals
      @client.cancel_all_goals
    end

    # Wait until action server starts with timeout.
    # It waits until /status message has come.
    # @param [Float] timeout_sec set timeout [sec]
    # @return [Bool] true: result has come, false: timeouted.
    def wait_for_server(timeout_sec=10.0)
      @client.wait_for_server(timeout_sec)
    end

    # Wait until result comes with timeout.
    # @param [Float] timeout_sec set timeout [sec]
    # @return [Bool] true: result has come, false: timeouted.
    def wait_for_result(timeout_sec=10.0)
      @last_goal_handle.wait_for_result(timeout_sec)
    end
  end

end
