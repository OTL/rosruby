# ros/master.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# == ruby ROS Master
#
#

require 'xmlrpc/client'
require 'ros/xmlrpcserver'
require 'ros/name'
require 'ros/slave_proxy'
require 'thread'

module ROS

  # ROS Master
  # @see http://ros.org/wiki/ROS/Master_API
  #
  class Master

    include Name

    # ROS parameter
    class Parameter

      # @param [String] key parameter key string
      # @param [Object] value parameter value for key
      def initialize(key, value)
        @key = key
        @value = value
      end
      attr_accessor :key
      attr_accessor :value
    end

    # parameter subscriber
    class ParameterSubscriber

      # @param [String] caller_id caller_id of subscriber node
      # @param [String] api XMLRPC URI of subscriber
      # @param [String] key key for parameter
      def initialize(caller_id, api, key)
        @caller_id = caller_id
        @api = api
        @key = key
      end

      # Get caller_id.
      # @return [String] caller_id
      attr_accessor :caller_id

      # Get key of parameter.
      # @return [String] key
      attr_accessor :key

      # Get api URI of this subscriber.
      # @return [String] URI of the subscriber.
      attr_accessor :api
    end

    # service server
    class ServiceServer

      # @param [String] caller_id caller_id of service server
      # @param [String] service_name name of service
      # @param [String] api XMLRPC URI of service server node
      # @param [String] service_api Service URI
      def initialize(caller_id, service_name, api, service_api)
        @caller_id = caller_id
        @name = service_name
        @api = api
        @service_api = service_api
      end


      # Get caller_id.
      # @return [String] caller_id
      attr_accessor :caller_id

      # Get the name of service.
      # @return [String] name of service.
      attr_accessor :name

      # Get TCPROS api URI.
      # @return [String] URI of service (TCPROS URI).
      attr_accessor :service_api

      # Get XMLRPC URI.
      # @return [String] URI of service server (XMLRPC URI)
      attr_accessor :api
    end

    # subscriber of topic
    class Subscriber

      # @param [String] caller_id caller_id of subscriber node
      # @param [String] topic_name name of topic
      # @param [String] api XMLRPC URI of subscriber node
      def initialize(caller_id, topic_name, topic_type, api)
        @caller_id = caller_id
        @name = topic_name
        @msg_type = topic_type
        @api = api
      end

      # Get caller_id.
      # @return [String] caller_id
      attr_accessor :caller_id

      # Get the name of topic.
      # @return [String] name of topic.
      attr_accessor :name

      # Get type of topic.
      # @return [String] type of topic in String.
      attr_accessor :msg_type

      # Get XMLRPC URI.
      # @return [String] URI of this publisher (XMLRPC URI)
      attr_accessor :api
    end

    # Publisher struct for Master
    class Publisher
      # @param [String] caller_id caller_id of publisher node
      # @param [String] topic_name name of topic
      # @param [String] api XMLRPC URI of publisher node
      def initialize(caller_id, topic_name, topic_type, api)
        @caller_id = caller_id
        @name = topic_name
        @msg_type = topic_type
        @api = api
      end

      # Get caller_id.
      # @return [String] caller_id
      attr_accessor :caller_id

      # Get the name of topic.
      # @return [String] name of topic.
      attr_accessor :name

      # Get type of topic.
      # @return [String] type of topic in String.
      attr_accessor :msg_type

      # Get XMLRPC API URI
      # @return [String] URI of this publisher (XMLPRC URI).
      attr_accessor :api
    end

    # kill old node if the same caller_id node is exits.
    # @param [String] caller_id new node's caller_id
    # @param [String] api new node's XMLRPC URI
    def kill_same_name_node(caller_id, api)
      delete_api = nil
      [@publishers, @subscribers, @services].each do |list|
        list.each do |pub|
          if pub.caller_id == caller_id and pub.api != api
            puts "killing #{caller_id}"
            delete_api = pub.api
            break
          end
        end
      end
      if delete_api
        proxy = SlaveProxy.new('/master', delete_api)
        begin
          proxy.shutdown("registered new node #{delete_api}")
        rescue
        end
        # delete
        [@publishers, @subscribers, @services].each do |list|
          list.delete_if {|x| x.api == delete_api}
        end
      end
    end

    # Delete connection of this api (XMLRPC URI).
    # @param [String] api URI of node to delete connection.
    def delete_connection(api)
      @subscribers.delete_if {|x| x.api == api}
      @publishers.delete_if {|x| x.api == api}
      @services.delete_if {|x| x.api == api}
    end

    # Initialize XMLRPC Server.
    # Master#start must be called to be started.
    # @param [String] master_uri uri of master
    def initialize(master_uri=ENV['ROS_MASTER_URI'])
      @master_uri = master_uri
      uri = URI.parse(@master_uri)
      @services = []
      @publishers = []
      @subscribers = []
      @parameters = []
      @param_subscribers = []
      @queue = Queue.new
      @server = XMLRPCServer.new(uri.port, uri.host)

      @server.set_default_handler do |method, *args|
        puts "unhandled call with #{method}, #{args}"
        [0, "I DON'T KNOW", 0]
      end

      @server.add_handler('registerService') do |caller_id, service_name, service_api, caller_api|
        service_name = canonicalize_name(service_name)
        kill_same_name_node(caller_id, caller_api)
        @services.push(ServiceServer.new(caller_id, service_name, caller_api, service_api))
        [1, "registered", 0]
      end

      @server.add_handler('unregisterService') do |caller_id, service_name, service_api|
        service_name = canonicalize_name(service_name)
        before = @services.length
        @services.delete_if {|x| x.name == service_name and x.caller_id == caller_id}
        after = @services.length
        [1, "deleted", before - after]
      end

      @server.add_handler('registerSubscriber') do |caller_id, topic_name, type, api|
        topic_name = canonicalize_name(topic_name)
        kill_same_name_node(caller_id, api)
        @subscribers.push(Subscriber.new(caller_id, topic_name, type, api))
        pub_apis = @publishers.select {|x|x.name == topic_name and x.msg_type == type}.map {|x| x.api }
        [1, "registered", pub_apis]
      end

      @server.add_handler('unregisterSubscriber') do |caller_id, topic_name, api|
        topic_name = canonicalize_name(topic_name)
        before = @subscribers.length
        @subscribers.delete_if {|x| x.name == topic_name and x.caller_id == caller_id}
        after = @subscribers.length
        [1, "deleted", before - after]
      end

      @server.add_handler('registerPublisher') do |caller_id, topic_name, type, api|
        topic_name = canonicalize_name(topic_name)
        kill_same_name_node(caller_id, api)
        @publishers.push(Publisher.new(caller_id, topic_name, type, api))
        sub_apis = @subscribers.select {|x|x.name == topic_name and x.msg_type == type}.map {|x| x.api }
        if not sub_apis
          sub_apis = []
        end
        pub_apis = @publishers.select {|x|x.name == topic_name and x.msg_type == type}.map {|x| x.api }
        @queue.push(proc{
                      sub_apis.each do |s_api|
                        proxy = SlaveProxy.new('/master', s_api)
                        begin
                          proxy.publisher_update(topic_name, pub_apis)
                        rescue => e
                          p e.faultCode
                          p e.faultString
                          delete_connection(s_api)
                        end
                      end
                    })
        [1, "registered", sub_apis]
      end

      @server.add_handler('unregisterPublisher') do |caller_id, topic_name, api|
        topic_name = canonicalize_name(topic_name)
        before = @publishers.length
        @publishers.delete_if {|x| x.name == topic_name and x.caller_id == caller_id}
        pub_apis = @publishers.select {|x|x.name == topic_name and x.caller_id == caller_id}.map {|x| x.api }
        sub_apis = @subscribers.select {|x|x.name == topic_name}.map {|x| x.api }
        if not sub_apis
          sub_apis = []
        end
#        @queue.push(proc{
                      sub_apis.each do |s_api|
                        proxy = SlaveProxy.new('/master', s_api)
                        begin
                          proxy.publisher_update(topic_name, pub_apis)
                        rescue => e
                          p e.faultCode
                          p e.faultString
                          delete_connection(s_api)
                        end
                      end
 #                   })
        after = @publishers.length
        [1, "deleted", before - after]
      end

      @server.add_handler('getPid') do |caller_id|
        [1, "ok", $$]
      end

      @server.add_handler('lookupNode') do |caller_id, node_name|
        pub = @publishers.select {|x| x.caller_id == node_name}
        sub = @subscribers.select {|x| x.caller_id == node_name}
        service = @services.select {|x| x.caller_id == node_name}
        if not pub.empty?
          [1, "found", pub.first.api]
        elsif not sub.empty?
          [1, "found", sub.first.api]
        elsif not service.empty?
          [1, "found", service.first.api]
        else
          [0, "not found", 0]
        end
      end

      @server.add_handler('getPublishedTopics') do |caller_id, subgraph|
        if subgraph == ''
          [1, "ok", @publishers.map {|x| [x.name, x.msg_type]}]
        else
          [1, "ok", @publishers.select {|x| not x.caller_id.scan(/^#{subgraph}/).empty?}.map {|x| [x.name, x.msg_type]}]
        end
      end

      @server.add_handler('getSystemState') do |caller_id|
        def convert_info_to_list(info)
          list = []
          info.keys.each do |key|
            list.push([key, info[key]])
          end
          list
        end

        pub_info = {}
        @publishers.each do |pub|
          if pub_info[pub.name]
            pub_info[pub.name].push(pub.caller_id)
          else
            pub_info[pub.name]= [pub.caller_id]
          end
        end

        sub_info = {}
        @subscribers.each do |sub|
          if sub_info[sub.name]
            sub_info[sub.name].push(sub.caller_id)
          else
            sub_info[sub.name]= [sub.caller_id]
          end
        end

        ser_info = {}
        @services.each do |ser|
          if ser_info[ser.name]
            ser_info[ser.name].push(ser.caller_id)
          else
            ser_info[ser.name]= [ser.caller_id]
          end
        end

        [1, "ok", [convert_info_to_list(pub_info),
                   convert_info_to_list(sub_info),
                   convert_info_to_list(ser_info)]]
      end

      @server.add_handler('getUri') do |caller_id|
        [1, "ok", @master_uri]
      end

      @server.add_handler('lookupService') do |caller_id, service|
        ser = @services.select {|x| x.name == service}
        if ser.empty?
          [0, "fail", 0]
        else
          [1, "ok", ser.first.service_api]
        end
      end

      ## parameters
      @server.add_handler('deleteParam') do |caller_id, key|
        key = canonicalize_name(key)
        before = @parameters.length
        @parameters.delete_if {|x| x.key == key}
        after = @parameters.length

        if before == after
          [0, "[#{key}] is not exists", 0]
        else
          [1, "ok", 0]
        end
      end

      @server.add_handler('setParam') do |caller_id, key, value|
        key = canonicalize_name(key)
        exist_param = @parameters.select {|x| x.key == key}
        if exist_param.empty?
          @parameters.push(Parameter.new(key, value))
        else
          exist_param.first.value = value
        end
        @param_subscribers.each do |x|
          if x.key == key
            begin
              proxy = SlaveProxy.new('/master', x.api)
              proxy.param_update(key, value)
            rescue
            end
          end
        end
        [1, "ok", 0]
      end

      @server.add_handler('getParam') do |caller_id, key|
        key = canonicalize_name(key)
        param = @parameters.select {|x| x.key == key}
        if param.empty?
          [0, "no such param [#{key}]", 0]
        else
          [1, "ok", param.first.value]
        end
      end

      @server.add_handler('searchParam') do |caller_id, key|
        key = canonicalize_name(key)
        if key == ''
          param = @parameters
        else
          param = @parameters.select {|x| not x.key.scan(/#{key}/).empty?}
        end
        if param.empty?
          [-1, "no param", 0]
        else
          [1, "ok", param.first.key]
        end
      end

      @server.add_handler('subscribeParam') do |caller_id, caller_api, key|
        key = canonicalize_name(key)
        @param_subscribers.push(ParameterSubscriber.new(caller_id, caller_api, key))
        params = @parameters.select {|x| x.key == key}
        if params.empty?
          [1, "ok", []]
        else
          [1, "ok", params.map {|x| x.value}]
        end
      end

      @server.add_handler('unsubscribeParam') do |caller_id, caller_api, key|
        key = canonicalize_name(key)
        before = @param_subscribers.length
        @param_subscribers.delete_if {|x| x.api == caller_api and x.key == key}
        after = @param_subscribers.length
        [1, "ok", before - after]
      end

      @server.add_handler('hasParam') do |caller_id, key|
        key = canonicalize_name(key)
        params = @parameters.select {|x| x.key == key}
        if params.empty?
          [0, "no", false]
        else
          [1, "ok", params.first.value]
        end
      end

      @server.add_handler('getParamNames') do |caller_id|
        [1, "ok", @parameters.map{|x| x.key}]
      end

      # not documented api
      @server.add_handler('getTopicTypes') do |caller_id|
        [1, "ok", @publishers.map {|x| [x.name, x.msg_type]} | @subscribers.map {|x| [x.name, x.msg_type]}]
      end

    end

    # start server and set default parameters
    def start
      puts "=== starting Ruby ROS master @#{@master_uri} ==="
      @parameters.push(Parameter.new('/rosversion', '1.8.6'))
      @parameters.push(Parameter.new('/rosdistro', 'fuerte'))
      @thread = Thread.new do
        while true
          procs = []
          # lock here
          proc_obj = @queue.pop
          procs.push(proc_obj)
          while not @queue.empty?
            proc_obj = @queue.pop
            procs.push(proc_obj)
          end
          # wait until server returns xmlrpc response...
          sleep 0.2
          begin
            procs.each {|x| x.call}
          rescue => e
            p 'error!'
            p e.faultString
          end
        end
      end
      @server.serve
      self
    end
  end
end
