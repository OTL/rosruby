require 'ros'
require 'timeout'

require 'actionlib_msgs/GoalStatus'
require 'actionlib_msgs/GoalStatusArray'
require 'actionlib_msgs/GoalID'

module Actionlib

  class Client

    @@goal_id = 1

    def initialize(node, action_name, spec)
      @spec = spec
      spec_instance = spec.new
      @goal_class = spec_instance.action_goal.class
      @result_class = spec_instance.action_result.class
      @feedback_class = spec_instance.action_feedback.class
      @node = node
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
        @last_result = msg.result
      end

      @feedback_callback = nil
      @feedback_subscriber = node.subscribe("#{action_name}/feedback",
                                            @feedback_class) do |msg|
        if @feedback_callback
          @feedback_callback.call(msg.feedback)
        end
      end
    end

    def send_goal(goal, feedback_callback=nil)
      @feedback_callback = feedback_callback

      action_goal = @goal_class.new
      action_goal.header.stamp = ROS::Time::now
      action_goal.goal = goal
      action_goal.goal_id = generate_id
      @goal_publisher.publish(action_goal)
    end

    def cancel_all_goals
      cancel_msg = Actionlib_msgs::GoalID.new
      cancel_msg.stamp = ROS::Time.new(0.0)
      cancel_msg.id = ""
      @cancel_publisher.publish(cancel_msg)
    end

    def wait_for_server(timeout_sec=3.0)
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

    def wait_for_result(timeout_sec=3.0)
      begin
        timeout(timeout_sec) do
          while not @last_result
            sleep 0.1
            @node.spin_once
          end
          @last_result
        end
      rescue Timeout::Error
        nil
      end
    end

    :private

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
