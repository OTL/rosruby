require "xmlrpc/client"

module ROS

  class ParameterManager

    def initialize(caller_id)
      @caller_id = caller_id
      @server = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
    end

    def get_param(key)
      result = server.call("getParam", @caller_id, key)
      if result[0] == 1
        return result[2]
      end
      return false
    end
    
    def set_param(key, value)
      result = server.call("setParam", @caller_id, key, value)
      if result[0] == 1
        return true
      end
      return false
    end
  end
end
