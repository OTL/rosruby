require 'ros'

require 'actionlib/action_server'

module Actionlib

  class SimpleActionServer

    def initialize(node, action_name, spec, options={})
      @server = ActionServer.new(node, action_name, spec, options)
    end

    def start(&callback)
      @server.start do |goal, handle|
        @current_handle = handle
        callback.call(goal)
      end
    end

    def publish_feedback(feedback)
      @current_handle.publish_feedback(Actionlib_msgs::GoalStatus::ACTIVE,
                                       feedback,
                                       @current_handle.goal_id)
    end

    def set_succeeded(result=nil)
      @current_handle.set_succeeded(result)
    end

    def set_canceled(result=nil)
      @current_handle.set_canceled(result)
    end

    def set_aborted(result=nil)
      @current_handle.set_aborted(result)
    end

    def shutdown
      @server.shutdown
    end

  end

end
