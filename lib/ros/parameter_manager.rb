# ros/parameter_manager.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# =Control Parameter Server Interface
#
# ROS parameter sever inteface.
# API document is here http://ros.org/wiki/ROS/Parameter%20Server%20API
#
require "xmlrpc/client"

module ROS

  class ParameterManager

    def initialize(master_uri, caller_id, remappings)
      @caller_id = caller_id
      @master_uri = master_uri
      @remappings = remappings
      @server = XMLRPC::Client.new2(@master_uri)
    end

    def get_param(key)
      if @remappings[key]
        return @remappings[key]
      end
      code, message, value = @server.call("getParam", @caller_id, key)
      case code
      when 1
        return value
      else
        return nil
      end
    end

    def set_param(key, value)
      code, message, value = @server.call("setParam", @caller_id, key, value)
      case code
      when 1
        return true
      when -1
        raise message
      else
        return false
      end
    end

    def delete_param(key)
      code, message, value = @server.call("deleteParam", @caller_id, key)
      case code
      when 1
        return true
      when -1
        raise message
      else
        return false
      end
    end

    def search_param(key)
      code, message, value = @server.call("searchParam", @caller_id, key)
      case code
      when 1
        return value
      when -1
        raise message
      else
        return false
      end
    end

    def has_param(key)
      code, message, value = @server.call("hasParam", @caller_id, key)
      case code
      when 1
        return value
      when -1
        raise message
      else
        return false
      end
    end

    def get_param_names
      code, message, value = @server.call("getParamNames", @caller_id)
      case code
      when 1
        return value
      when -1
        raise message
      else
        return false
      end
    end
  end
end
