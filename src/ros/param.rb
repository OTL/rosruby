require "xmlrpc/client"

module ROS

  module Param

    def get_param_with_caller_id(caller_id, key)
      paramerter_server = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
      result = paramerter_server.call("getParam", caller_id, key)
      if result[0] == 1
        return result[2]
      end
      return false
    end
    
    def set_param_with_caller_id(caller_id, key, value)
      paramerter_server = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
      result = paramerter_server.call("setParam", caller_id, key, value)
      if result[0] == 1
        return true
      end
      return false
    end

  end
  
end

#setParam('hoge', "/hoge", 5)
#puts getParam('hoge', "/hoge")
