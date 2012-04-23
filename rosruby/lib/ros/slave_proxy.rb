# ros/slave_proxy.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# = ROS Slave Proxy
# you can access to ROS Slave nodes.
#
#

require 'xmlrpc/client'

module ROS

  # = ROS Slave Proxy
  # you can access to ROS Slave nodes.
  # reference: http://ros.org/wiki/ROS/Slave_API
  #
  class SlaveProxy

    def initialize(caller_id, slave_uri)
      @caller_id = caller_id
      @slave_uri = slave_uri
      @proxy = XMLRPC::Client.new2(@slave_uri).proxy
    end
    
    def get_bus_stats
      code, message, stats = @proxy.getBusStats(@caller_id)
      if code == 1
        return stats
      else
        raise message
      end
    end

    def get_bus_info
      code, message, info = @proxy.getBusInfo(@caller_id)
      if code == 1
        return info
      else
        raise message
      end
    end

    def get_master_uri
      code, message, uri = @proxy.getMasterUri(@caller_id)
      if code == 1
        return uri
      else
        raise message
      end
    end

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

    def get_pid
      code, message, pid = @proxy.getPid(@caller_id)
      if code == 1
        return pid
      else
        raise message
      end
    end

    def get_subscriptions
      code, message, topic = @proxy.getSubscriptions(@caller_id)
      if code == 1
        return topic
      else
        raise message
      end
    end

    def get_publications
      code, message, topic = @proxy.getPublications(@caller_id)
      if code == 1
        return topic
      else
        raise message
      end
    end

    def param_update(param_key, param_value)
      code, message, val = @proxy.paramUpdate(@caller_id, param_key, param_value)
      if code == 1
        return true
      else
        raise message
      end
    end

    def publisher_update(topic, publishers)
      code, message, val = @proxy.publisherUpdate(@caller_id, topic, publishers)
      if code == 1
        return true
      else
        raise message
      end
    end

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
    
    attr_accessor :slave_uri, :caller_id
  end
end
