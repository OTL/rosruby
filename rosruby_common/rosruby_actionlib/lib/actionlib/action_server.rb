require 'ros'
require 'timeout'

require 'actionlib_msgs/GoalStatus'
require 'actionlib_msgs/GoalStatusArray'
require 'actionlib_msgs/GoalID'

module Actionlib

  class Server

    def initialize(node, action_name, spec)
      @spec = spec
      @action_name = action_name
      spec_instance = spec.new
      @goal_class = spec_instance.action_goal.class
      @result_class = spec_instance.action_result.class
      @feedback_class = spec_instance.action_feedback.class
      @node = node
    end

    def start(&callback)
      @callback = callback
      @goal_subscriber = @node.subscribe("#{@action_name}/goal", @goal_class) do |msg|
        p 'goal come!!'
        @callback.call(msg.goal)
      end

      @cancel_subscriber = @node.subscribe("#{@action_name}/cancel", Actionlib_msgs::GoalID) do |msg|
      end
      @status_publisher = @node.advertise("#{@action_name}/status",
                                         Actionlib_msgs::GoalStatusArray)
      @result_publisher = @node.advertise("#{@action_name}/result", @result_class)
      @feedback_publisher = @node.advertise("#{@action_name}/feedback", @feedback_class)
      @is_running = true
      @thread = Thread.new do
        while @is_running
          sleep 0.1
          status = Actionlib_msgs::GoalStatusArray.new
          @status_publisher.publish(status)
        end
      end
      END {self.shutdown}
    end

    def set_succeeded
      result = @result_class.new
      result.status = Actionlib_msgs::GoalStatus::SUCCEEDED
      @result_publisher.publish(result)
    end

    def shutdown
      if @is_running
        @is_running = false
        @thread.join
      end
    end

  end

end
