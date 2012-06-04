#  actionlib/action_client.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
require 'ros'
require 'timeout'

require 'actionlib_msgs/GoalStatus'
require 'actionlib_msgs/GoalStatusArray'
require 'actionlib_msgs/GoalID'

module Actionlib

  ##
  # Goal handle of action client
  class ClientGoalHandle

    # @param [ActionClient] action client that created this goal.
    # @param [Object] goal object.
    # @param [Class] spec Action spec.
    def initialize(client, action_goal, spec)
      @client = client
      @goal = action_goal
      @spec = spec
      @goal_id = action_goal.goal_id
      @result = nil
    end

    # Cancel this action goal.
    def cancel
      @client.publish_cancel(@goal_id)
    end

    # Set result. internal use.
    def set_result(result) #:nodoc:
      @result = result
    end

    # Wait until result comes with timeout.
    # @param [Float] timeout_sec set timeout [sec]
    # @return [Bool] true: result has come, false: timeouted.
    def wait_for_result(timeout_sec=10.0)
      begin
	timeout(timeout_sec) do
	  while not @result
	    sleep 0.1
	    @client.spin_once
	  end
	  @result
	end
      rescue Timeout::Error
	nil
      end
    end

    # goal
    attr_reader :goal

    # goal id
    attr_reader :goal_id

    # result
    attr_reader :result
  end

  # Action client
  class ActionClient

    # current goal id
    @@goal_id = 1

    # @param [ROS::Node] node ros node to pub/sub.
    # @param [String] action_name name of the action.
    # @param [Class] spec class of action
    def initialize(node, action_name, spec)
      @spec = spec
      spec_instance = spec.new
      @goal_class = spec_instance.action_goal.class
      @result_class = spec_instance.action_result.class
      @feedback_class = spec_instance.action_feedback.class
      @node = node
      @goal_handles = []
      @goal_publisher = node.advertise("#{action_name}/goal", @goal_class)
      @cancel_publisher = node.advertise("#{action_name}/cancel", Actionlib_msgs::GoalID)
      @last_status = nil
      @status_subscriber = node.subscribe("#{action_name}/status",
					  Actionlib_msgs::GoalStatusArray) do |msg|
	@last_status = msg
      end
      @last_result = nil
      @result_subscriber = node.subscribe("#{action_name}/result",
					  @result_class) do |msg|
	@goal_handles.each do |handle|
	  # check if it is my goal
	  if msg.status.goal_id.id == handle.goal_id.id
	    handle.set_result(msg.result)
	    if @result_callback
	      @result_callback.call(msg.result)
	    end
	    @last_result = msg.result
	  end
	end
      end

      @feedback_callback = nil
      @feedback_subscriber = node.subscribe("#{action_name}/feedback",
					    @feedback_class) do |msg|
	@goal_handles.each do |handle|
	  # check if it is my goal
	  if msg.status.goal_id.id == handle.goal_id.id
	    if @feedback_callback
	      @feedback_callback.call(msg.feedback)
	    end
	  end
	end
      end
    end

    # Send a goal to action server.
    # @param [Object] goal ActionGoal object.
    # @param [Hash] options options
    # @option options [proc] :feedback_callback callback of /feedback
    # @option options [proc] :result_callback callback of /result
    # @return [ClientGoalHandle] handle of this goal.
    def send_goal(goal, options={})
      @feedback_callback = options[:feedback_callback]
      @result_callback = options[:result_callback]

      action_goal = @goal_class.new
      action_goal.header.stamp = ROS::Time::now
      action_goal.goal = goal
      action_goal.goal_id = generate_id
      @goal_publisher.publish(action_goal)
      goal_handle = ClientGoalHandle.new(self, action_goal, @spec)
      @goal_handles.push(goal_handle)
      if options[:wait]
	wait_for_server
      end
      goal_handle
    end

    # Cancel this goal id's goal
    # @param [Actionlib_msgs::GoalID] goal_id goal id
    def publish_cancel(goal_id)
      @cancel_publisher.publish(goal_id)
    end

    # Cancel all goals of this client.
    def cancel_all_goals
      cancel_msg = Actionlib_msgs::GoalID.new
      cancel_msg.stamp = ROS::Time.new(0.0)
      cancel_msg.id = ""
      publish_cancel(cancel_msg)
      @goals = []
    end

    # Wait until action server starts with timeout.
    # It waits until /status message has come.
    # @param [Float] timeout_sec set timeout [sec]
    # @return [Bool] true: result has come, false: timeouted.
    def wait_for_server(timeout_sec=10.0)
      begin
	timeout(timeout_sec) do
	  while not @last_status
	    sleep 0.1
	    @node.spin_once
	  end
	  true
	end
      rescue Timeout::Error
	false
      end
    end

    # spin this node at once
    def spin_once
      @node.spin_once
    end

    :private

    # generate uniq id
    # @return [Actionlib_msgs::GoalID] goal id
    def generate_id
      id = @@goal_id
      @@goal_id += 1
      now = ROS::Time::now
      goal_id = Actionlib_msgs::GoalID.new
      goal_id.stamp = now
      goal_id.id =  "#{@node.node_name}-#{id}-#{now.to_sec}"
      goal_id
    end
  end

end
