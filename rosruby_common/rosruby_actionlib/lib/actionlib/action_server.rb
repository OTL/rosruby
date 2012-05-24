require 'ros'
require 'timeout'

require 'actionlib_msgs/GoalStatus'
require 'actionlib_msgs/GoalStatusArray'
require 'actionlib_msgs/GoalID'

module Actionlib

  class ServerGoalHandle
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

    def publish_feedback(feedback)
      @server.publish_feedback(Actionlib_msgs::GoalStatus::ACTIVE, feedback, @goal_id)
    end

    def set_succeeded(result=nil)
      if not result
        result = @result_class.new.result
      end
      @server.publish_result(Actionlib_msgs::GoalStatus::SUCCEEDED, result, @goal_id)
    end

    def set_canceled(result=nil)
      if not result
        result = @result_class.new.result
      end
      @server.publish_result(Actionlib_msgs::GoalStatus::PREEMPTED, result, @goal_id)
    end

    def set_aborted(result=nil)
      if not result
        result = @result_class.new.result
      end
      @server.publish_result(Actionlib_msgs::GoalStatus::ABORTED, result, @goal_id)
    end

    attr_reader :goal_id
    attr_reader :goal
    attr_reader :status
  end


  class ActionServer

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

    def publish_result(status, result, goal_id)
      action_result = @result_class.new
      action_result.header.stamp = ROS::Time::now
      action_result.result = result
      action_result.status.status = status
      action_result.status.goal_id = goal_id
      @result_publisher.publish(action_result)
      set_status(goal_id, status)
    end

    def publish_feedback(status, feedback, goal_id)
      action_feedback = @result_class.new
      action_feedback.header.stamp = ROS::Time::now
      action_feedback.feedback = feedback
      action_feedback.status = status
      action_feedback.status.goal_id = goal_id
      @feedback_publisher.publish(action_feedback)
      set_status(goal_id, status)
    end

    def shutdown
      if @is_running
        @is_running = false
        @thread.join
      end
    end

    :private

    def set_status(goal_id, status)
      @goal_status_array.status_list.each do |x|
        if x.goal_id.id == goal_id.id
          x.status = status
        end
      end
    end

  end

end
