require 'ros'

require 'actionlib/action_client'

module Actionlib

  class SimpleActionClient

    def initialize(node, action_name, spec)
      @client = ActionClient.new(node, action_name, spec)
      @last_goal_handle = nil
    end

    def send_goal(goal, options={})
      @last_goal_handle = @client.send_goal(goal, options)
    end

    def cancel_all_goals
      @client.cancel_all_goals
    end

    def wait_for_server(timeout_sec=10.0)
      @client.wait_for_server(timeout_sec)
    end

    def wait_for_result(timeout_sec=10.0)
      @last_goal_handle.wait_for_result(timeout_sec)
    end
  end

end
