# ros/master_proxy.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# = ROS Master Proxy
# you can access to ROS Master easily.
#
#

require 'xmlrpc/client'

module ROS

  # = ROS Master Proxy
  # you can access to ROS Master easily.
  #
  # reference: http://ros.org/wiki/ROS/Master_API
  #
  class MasterProxy

    def initialize(caller_id, master_uri, slave_uri)
      @caller_id = caller_id
      @master_uri = master_uri
      @slave_uri = slave_uri
      @proxy = XMLRPC::Client.new2(@master_uri).proxy
    end

    def register_service(service, service_api)
      code, message, val = @proxy.registerService(@caller_id,
                                                  service,
                                                  service_api,
                                                  @slave_uri)
      if code == 1
        return true
      else
        raise message
      end
    end

    def unregister_service(service, service_api)
      code, message, val = @proxy.unregisterService(@caller_id,
                                                    service,
                                                    service_api)
      if code == 1
        return true
      elsif code == 0
        puts message
        return true
      else
        raise message
      end
    end

    def register_subscriber(topic, topic_type)
      code, message,val = @proxy.registerSubscriber(@caller_id,
                                                    topic,
                                                    topic_type,
                                                    @slave_uri)
      if code == 1
        val
      elsif code == 0
        puts message
        val
      else
        raise message
      end
    end

    def unregister_subscriber(topic)
      code, message,val = @proxy.unregisterSubscriber(@caller_id,
                                                      topic,
                                                      @slave_uri)
      if code == 1
        return true
      elsif code == 0
        puts message
        return true
      else
        raise message
      end
    end

    def register_publisher(topic, topic_type)
      code, message, uris = @proxy.registerPublisher(@caller_id,
                                                     topic,
                                                     topic_type,
                                                     @slave_uri)
      if code == 1
        uris
      else
        raise message
      end
    end

    def unregister_publisher(topic)
      code, message, val = @proxy.unregisterPublisher(@caller_id,
                                                      topic,
                                                      @slave_uri)
      if code == 1
        return val
      elsif code == 0
        puts message
        return true
      else
        raise message
      end
    end

    def lookup_node(node_name)
      code, message, uri = @proxy.lookupNode(@caller_id, node_name)
      if code == 1
        uri
      else
        nil
      end
    end

    def get_published_topics(subgraph='')
      code, message, topics = @proxy.getPublishedTopics(@caller_id, subgraph)
      if code == 1
        return topics
      elsif
        raise message
      end
    end

    def get_system_state
      code, message, state = @proxy.getSystemState(@caller_id)
      if code == 1
        return state
      else
        raise message
      end
    end

    def get_uri
      code, message, uri = @proxy.getUri(@caller_id)
      if code == 1
        return uri
      else
        raise message
      end
    end

    def lookup_service(service)
      code, message, uri = @proxy.lookupService(@caller_id, service)
      if code == 1
        uri
      else
        false
      end
    end

    def master_uri
      @master_uri
    end

    def master_uri=(uri)
      @master_uri = uri
      @proxy = XMLRPC::Client.new2(@master_uri).proxy
    end

    attr_accessor :slave_uri, :caller_id
  end
end
