#  actionlib/simple_action_server.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'ros'

require 'actionlib/action_server'

# ruby ROS Actionlib module.
module Actionlib

  class SimpleActionServer

    # @param [ROS::Node] node node for pub/sub.
    # @param [String] action_name name of this action.
    # @param [Class] spec class object of this Action.
    # @param [Hash] options option
    # @option [proc] :cancel_callback call back for /cancel
    def initialize(node, action_name, spec, options={})
      @server = ActionServer.new(node, action_name, spec, options)
    end

    # start serve in a thread
    # @param [proc] callback callback for /goal
    def start(&callback)
      @server.start do |goal, handle|
        @current_handle = handle
        callback.call(goal)
      end
    end

    # Publishes feedback.
    # @param [ROS::Message] feedback actionlib feedback.
    def publish_feedback(feedback)
      @current_handle.publish_feedback(Actionlib_msgs::GoalStatus::ACTIVE,
                                       feedback,
                                       @current_handle.goal_id)
    end

    # set 'this is succeeded' with a result.
    # @param [ROS::Message] result actionlib result object.
    def set_succeeded(result=nil)
      @current_handle.set_succeeded(result)
    end

    # set this goal has canceled with a result.
    # @param [ROS::Message] result actionlib result object.
    def set_canceled(result=nil)
      @current_handle.set_canceled(result)
    end

    # set this goal has aborted with a result.
    # @param [ROS::Message] result actionlib result object.
    def set_aborted(result=nil)
      @current_handle.set_aborted(result)
    end

    # Shutdown this server.
    def shutdown
      @server.shutdown
    end

  end

end
