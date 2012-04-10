require "xmlrpc/client"

module ROS

  class ParameterManager

    def initialize(caller_id, node)
      @node = node
      @caller_id = caller_id
      @server = XMLRPC::Client.new2(node.master_uri)
    end

    def get_param(key)
      result = @server.call("getParam", @caller_id, key)
      if result[0] == 1
        return result[2]
      end
      return false
    end
    
    def set_param(key, value)
      result = @server.call("setParam", @caller_id, key, value)
      if result[0] == 1
        return true
      end
      return false
    end
  end
end
