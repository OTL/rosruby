#  actionlib/action_server.rb
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

  # Goal hander of action server.
  class ServerGoalHandle

    # @param [ActionServer] server server of this goal.
    # @param [ROS::Message] goal object.
    # @param [ROS::Message] status object.
    # @param [Class] spec Action spec.
    def initialize(server, action_goal, status, spec)
      @server = server
      @goal = action_goal.goal
      @spec = spec
      spec_instance = spec.new
      @result_class = spec_instance.action_result.class
      @feedback_class = spec_instance.action_feedback.class
      @goal_id = action_goal.goal_id
      @status = status
    end

    # broadcast a feedback object for clients.
    # @param [ROS::Message] feedback actionlib feedback object
    def publish_feedback(feedback)
      @server.publish_feedback(Actionlib_msgs::GoalStatus::ACTIVE, feedback, @goal_id)
    end

    # set 'this is succeeded' with a result.
    # @param [ROS::Message] result actionlib result object.
    def set_succeeded(result=nil)
      if not result
        result = @result_class.new.result
      end
      @server.publish_result(Actionlib_msgs::GoalStatus::SUCCEEDED, result, @goal_id)
    end

    # set this goal has canceled with a result.
    # @param [ROS::Message] result actionlib result object.
    def set_canceled(result=nil)
      if not result
        result = @result_class.new.result
      end
      @server.publish_result(Actionlib_msgs::GoalStatus::PREEMPTED, result, @goal_id)
    end

    # set this goal has aborted with a result.
    # @param [ROS::Message] result actionlib result object.
    def set_aborted(result=nil)
      if not result
        result = @result_class.new.result
      end
      @server.publish_result(Actionlib_msgs::GoalStatus::ABORTED, result, @goal_id)
    end

    # @param [Actionlib_msgs::GoalID] goal_id goal id
    attr_reader :goal_id

    # @param [ROS::Message] actionlib goal object
    attr_reader :goal

    # @param [ROS::Message] actionlib status object
    attr_reader :status
  end

  # Action server of Actionlib
  class ActionServer

    # @param [ROS::Node] node node for pub/sub.
    # @param [String] action_name name of this action.
    # @param [Class] spec class object of this Action.
    # @param [Hash] options option
    # @option [proc] :cancel_callback call back for /cancel
    def initialize(node, action_name, spec, options={})
      @spec = spec
      @action_name = action_name
      spec_instance = spec.new
      @goal_class = spec_instance.action_goal.class
      @result_class = spec_instance.action_result.class
      @feedback_class = spec_instance.action_feedback.class
      @cancel_callback = options[:cancel_callback]
      @node = node
    end

    # start serve in a thread
    # @param [proc] callback callback for /goal
    def start(&callback)
      @goal_callback = callback
      @goal_status_array = Actionlib_msgs::GoalStatusArray.new
      @goal_handles = []

      @current_goal = nil
      @goal_subscriber = @node.subscribe("#{@action_name}/goal", @goal_class) do |msg|
        @current_goal = msg
        status = Actionlib_msgs::GoalStatus.new
        status.status = Actionlib_msgs::GoalStatus::ACTIVE
        status.goal_id = msg.goal_id
        @goal_status_array.status_list.push(status)
        goal_handle = ServerGoalHandle.new(self, msg, status, @spec)
        @goal_handles.push(goal_handle)
        @goal_callback.call(msg.goal, goal_handle)
      end

      @cancel_subscriber = @node.subscribe("#{@action_name}/cancel",
                                           Actionlib_msgs::GoalID) do |msg|
        if msg.id == ""
          # cancel all
          @goal_handles.each do |handle|
            handle.set_canceled
          end
        else
          @goal_handles.each do |handle|
            if handle.goal_id.id == msg.id
              handle.set_canceled
            end
          end
        end
      end

      @status_publisher = @node.advertise("#{@action_name}/status",
                                         Actionlib_msgs::GoalStatusArray)
      @result_publisher = @node.advertise("#{@action_name}/result", @result_class)
      @feedback_publisher = @node.advertise("#{@action_name}/feedback", @feedback_class)

      @is_running = true
      ROS::Node::add_shutdown_hook(proc{self.shutdown})

      @thread = Thread.new do
        rate = ROS::Rate.new(5.0)
        while @is_running
          rate.sleep
          @status_publisher.publish(@goal_status_array)
          @goal_status_array.status_list.delete_if do |status|
            status.status == Actionlib_msgs::GoalStatus::SUCCEEDED or
              status.status == Actionlib_msgs::GoalStatus::ABORTED or
              status.status == Actionlib_msgs::GoalStatus::REJECTED
          end
        end
      end
    end

    # Publishes result.
    # @param [ROS::Message] status actionlib status message.
    # @param [ROS::Message] result actionlib result.
    # @param [Actionlib_msgs::GoalID] goal_id goal id.
    def publish_result(status, result, goal_id)
      action_result = @result_class.new
      action_result.header.stamp = ROS::Time::now
      action_result.result = result
      action_result.status.status = status
      action_result.status.goal_id = goal_id
      @result_publisher.publish(action_result)
      set_status(goal_id, status)
    end

    # Publishes feedback.
    # @param [ROS::Message] status actionlib status message.
    # @param [ROS::Message] feedback actionlib feedback.
    # @param [Actionlib_msgs::GoalID] goal_id goal id.
    def publish_feedback(status, feedback, goal_id)
      action_feedback = @result_class.new
      action_feedback.header.stamp = ROS::Time::now
      action_feedback.feedback = feedback
      action_feedback.status = status
      action_feedback.status.goal_id = goal_id
      @feedback_publisher.publish(action_feedback)
      set_status(goal_id, status)
    end

    # Shutdown this server.
    def shutdown
      if @is_running
        @is_running = false
        if not @thread.join(0.1)
          Thread::kill(@thread)
        end
      end
    end

    :private

    # Set status for a goal_id
    # @param [Actionlib_msgs::GoalID] goal_id goal id.
    # @param [ROS::Message] status status of goal id.
    def set_status(goal_id, status)
      @goal_status_array.status_list.each do |x|
        if x.goal_id.id == goal_id.id
          x.status = status
        end
      end
    end

  end

end
