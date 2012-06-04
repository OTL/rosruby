# ros/slave_proxy.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# == ROS Slave Proxy
# you can access to ROS Slave nodes.
#
#

require 'xmlrpc/client'

module ROS

  # you can access to ROS Slave nodes.
  # @see http://ros.org/wiki/ROS/Slave_API
  class SlaveProxy

    # @param [String] caller_id caller id of this node
    # @param [String] slave_uri URI to connect
    def initialize(caller_id, slave_uri)
      @caller_id = caller_id
      @slave_uri = slave_uri
      @proxy = XMLRPC::Client.new2(@slave_uri).proxy
    end

    # @return [Array] stats
    # @raise [RuntimeError] if fail
    def get_bus_stats
      code, message, stats = @proxy.getBusStats(@caller_id)
      if code == 1
        return stats
      else
        raise message
      end
    end

    # @return [Array] bus information
    # @raise [RuntimeError] if fail
    def get_bus_info
      code, message, info = @proxy.getBusInfo(@caller_id)
      if code == 1
        return info
      else
        raise message
      end
    end

    # @return [String] URI of master
    # @raise [RuntimeError] if fail
    def get_master_uri
      code, message, uri = @proxy.getMasterUri(@caller_id)
      if code == 1
        return uri
      else
        raise message
      end
    end

    # @param [String] msg message to slave (reason of shutdown request)
    # @raise [RuntimeError] if fail
    def shutdown(msg='')
      code, message, val = @proxy.shutdown(@caller_id, msg)
      if code == 1
        return true
      elsif code == 0
        return false
      else
        raise message
      end
    end

    # @return [Integer] pid of the slave process
    # @raise [RuntimeError] if fail
    def get_pid
      code, message, pid = @proxy.getPid(@caller_id)
      if code == 1
        return pid
      else
        raise message
      end
    end

    # @return [Array] topiccs
    # @raise [RuntimeError] if fail
    def get_subscriptions
      code, message, topic = @proxy.getSubscriptions(@caller_id)
      if code == 1
        return topic
      else
        raise message
      end
    end

    # @return [Array] publications
    # @raise [RuntimeError] if fail
    def get_publications
      code, message, topic = @proxy.getPublications(@caller_id)
      if code == 1
        return topic
      else
        raise message
      end
    end

    # @param [String] param_key  key for param
    # @param [String, Integer, Float, Boolean, Array] param_value  new value for key
    # @return [Boolean] true
    # @raise [RuntimeError] if fail
    def param_update(param_key, param_value)
      code, message, val = @proxy.paramUpdate(@caller_id, param_key, param_value)
      if code == 1
        return true
      else
        raise message
      end
    end

    # @param [String] topic name of topic
    # @param [Array] publishers array of publisher uri
    # @return [Boolean] true
    # @raise [RuntimeError] if fail
    def publisher_update(topic, publishers)
      code, message, val = @proxy.publisherUpdate(@caller_id, topic, publishers)
      if code == 1
        return true
      else
        raise message
      end
    end

    # @param [String] topic name of topic
    #
    def request_topic(topic, protocols)
      code, message, protocol = @proxy.requestTopic(@caller_id,
                                                    topic,
                                                    protocols)
      if code == 1
        return protocol
      else
        raise message
      end
    end

    # @return [String] URI of target
    attr_accessor :slave_uri

    # @return [String] caller_id of this caller
    attr_accessor :caller_id
  end
end
