# ros/master_proxy.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# == ROS Master Proxy
# access to ROS Master
#
#

require 'xmlrpc/client'

module ROS

  # == ROS Master Proxy
  # access to ROS Master.
  # @see http://ros.org/wiki/ROS/Master_API
  # But there are not documented API.
  #
  class MasterProxy

    #
    # @param [String] caller_id caller_id of this node
    # @param [String] master_uri URI of ROS Master
    # @param [String] slave_uri slave URI of this node
    def initialize(caller_id, master_uri, slave_uri)
      @caller_id = caller_id
      @master_uri = master_uri
      @slave_uri = slave_uri
      @proxy = XMLRPC::Client.new2(@master_uri).proxy
    end

    # register a service
    # @param [String] service name of service
    # @param [String] service_api service api uri
    # @return [Boolean] true success
    # @raise RuntimeError
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

    # unregister a service
    # @param [String] service name of service
    # @param [String] service_api service api uri
    # @return [Boolean] true success
    # @raise RuntimeError
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

    # register a subscriber
    # @param [String] topic topic name
    # @param [String] topic_type topic type
    # @return [Array] URI of current publishers
    # @raise [RuntimeError] if error
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

    # unregister a subscriber
    # @param [String] topic name of topic to unregister
    # @return [Boolean] true
    # @raise RuntimeError
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

    # register a publisher
    # @param [String] topic topic name of topic
    # @param [String] topic_type type of topic
    # @return [Array] URI of current subscribers
    # @raise RuntimeError
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

    # unregister a publisher
    # @param [String] topic name of topic
    # @return [Boolean] true
    # @raise RuntimeError
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
      return false
    end

    ##
    # this method is not described in the wiki.
    # subscribe to the parameter key.
    # @param [String] key name of parameter
    # @return [Boolean] true
    # @raise [RuntimeError] if fail
    def subscribe_param(key)
      code, message, uri = @proxy.subscribeParam(@caller_id, @slave_uri, key)
      if code == 1
        return true
      else
        raise message
      end
    end

    ##
    # unsubscribe to the parameter key.
    # this method is not described in the wiki.
    # @param [String] key name of parameter key
    # @return [Boolean] true
    # @raise [RuntimeError] if failt
    def unsubscribe_param(key)
      code, message, uri = @proxy.unsubscribeParam(@caller_id, @slave_uri, key)
      if code == 1
        return true
      else
        raise message
      end
    end

    # lookup a node by name.
    # @param [String] node_name
    # @return [String, nil] URI of the node if it is found. nil not found.
    def lookup_node(node_name)
      code, message, uri = @proxy.lookupNode(@caller_id, node_name)
      if code == 1
        uri
      else
        nil
      end
    end

    # get the all published topics
    # @param [String] subgraph namespace for check
    # @return [Array] topic names.
    # @raise
    def get_published_topics(subgraph='')
      code, message, topics = @proxy.getPublishedTopics(@caller_id, subgraph)
      if code == 1
        return topics
      elsif
        raise message
      end
    end

    # get system state
    # @return [Array] state
    def get_system_state
      code, message, state = @proxy.getSystemState(@caller_id)
      if code == 1
        return state
      else
        raise message
      end
    end

    # get the master URI
    # @return [String] uri
    # @raise
    def get_uri
      code, message, uri = @proxy.getUri(@caller_id)
      if code == 1
        return uri
      else
        raise message
      end
    end

    # look up a service by name
    # @param [String] service name of service
    # @return [String, nil] URI of service if found, nil not found.
    def lookup_service(service)
      code, message, uri = @proxy.lookupService(@caller_id, service)
      if code == 1
        uri
      else
        false
      end
    end

    # Master URI
    # @return [String] uri of master
    attr_reader :master_uri

    # set the master uri
    # @param [String] uri master uri
    # @return [MasterProxy] self
    def master_uri=(uri)
      @master_uri = uri
      @proxy = XMLRPC::Client.new2(@master_uri).proxy
      self
    end

    # Slave URI
    # @return [String]
    attr_accessor :slave_uri

    # caller id of this node
    # @return [String]
    attr_accessor :caller_id
  end
end
