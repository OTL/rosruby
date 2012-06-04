# ros/parameter_manager.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# == Control Parameter Server Interface
#
# ROS parameter sever inteface.
# API document is here http://ros.org/wiki/ROS/Parameter%20Server%20API
#
require "xmlrpc/client"

module ROS

  # ROS parameter sever inteface.
  # API document is here http://ros.org/wiki/ROS/Parameter%20Server%20API
  class ParameterManager

    # @param [String] master_uri URI of ROS Master (parameter server)
    # @param [String] caller_id caller_id of this node
    # @param [Hash] remappings remapps to use for local remappings
    def initialize(master_uri, caller_id, remappings)
      @caller_id = caller_id
      @master_uri = master_uri
      @remappings = remappings
      @server = XMLRPC::Client.new2(@master_uri)
    end

    ##
    # get parameter named 'key'
    # @param [String] key name of parameter
    # @return [String] parameter value
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

    ##
    # set parameter for 'key'
    # @param [String] key key of parameter
    # @param [String, Integer, Float, Boolean] value value of parameter
    # @return [Boolean] true if succeed
    # @raise
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

    ##
    # delete parameter 'key'
    # @param [String] key key for remove
    # @return [Boolean] return true if success, false if it is not exist
    def delete_param(key)
      code, message, value = @server.call("deleteParam", @caller_id, key)
      case code
      when 1
        return true
      else
        return false
      end
    end

    ##
    # search the all namespace for key
    # @param [String] key key for search
    # @return [Array] values
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

    ##
    # check if the master has the key
    # @param [String] key key for check
    # @return [String, Integer, Float, Boolean] value of key
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

    ##
    # get the all keys of parameters
    # @return [Array] all keys
    #
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
