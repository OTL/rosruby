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

require 'xmlrpc/server'
require 'xmlrpc/client'
require 'ros/name'

module ROS

  # ROS Master
  # @see http://ros.org/wiki/ROS/Master_API
  #
  class Master

    include Name

    # max slave connection
    MAX_CONNECTION = 100

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
      
      attr_accessor :caller_id
      attr_accessor :key
      attr_accessor :api
    end
    
    # service server
    class ServiceServer

      # @param [String] caller_id caller_id of service server
      # @param [String] service_name name of service
      # @param [String] service_api XMLRPC URI of service server node
      # @param [String] service_uri Service URI
      def initialize(caller_id, service_name, service_api, slave_uri)
        @caller_id = caller_id
        @name = service_name
        @api = service_api
        @uri = slave_uri
      end

      attr_accessor :caller_id
      attr_accessor :name
      attr_accessor :uri
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
        @type = topic_type
        @api = api
      end
      
      attr_accessor :caller_id
      attr_accessor :name
      attr_accessor :type
      attr_accessor :api
    end
    
    class Publisher
      # @param [String] caller_id caller_id of publisher node
      # @param [String] topic_name name of topic
      # @param [String] api XMLRPC URI of publisher node
      def initialize(caller_id, topic_name, topic_type, api)
        @caller_id = caller_id
        @name = topic_name
        @type = topic_type
        @api = api
      end
      
      attr_accessor :caller_id
      attr_accessor :name
      attr_accessor :type
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
            delete_api = pub.api
            break
          end
        end
      end
      if delete_api
        proxy = XMLRPC::Client.new2(delete_api).proxy  
        proxy.shutdown('/master', "registered new node #{api}")
        # delete
        [@publishers, @subscribers, @services].each do |list|
          list.delete_if {|x| x.api == delete_api}
        end
      end
    end

    # @param [String] master_uri uri of master
    def initialize(master_uri=ENV['ROS_MASTER_URI'])
      @master_uri = master_uri
      uri = URI.parse(@master_uri)
      @services = []
      @publishers = []
      @subscribers = []
      @parameters = []
      @param_subscribers = []
      @server = XMLRPC::Server.new(uri.port, uri.host, MAX_CONNECTION,
                                   $stderr, false, false)

      @server.set_default_handler do |method, *args|
        puts "unhandled call with #{method}, #{args}"
        [0, "I DON'T KNOW", 0]
      end
      
      @server.add_handler('registerService') do |caller_id, service_name, api, uri|
        service_name = canonicalize_name(service_name)
        kill_same_name_node(caller_id, api)
        @services.push(ServiceServer.new(caller_id, service_name, api, uri))
        [1, "registered", 0]
      end

      @server.add_handler('unregisterService') do |caller_id, service_name, api|
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
        pub_apis = @publishers.select {|x|x.name == topic_name and x.type == type}.map {|x| x.api }
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
        sub_apis = @subscribers.select {|x|x.name == topic_name and x.type == type}.map {|x| x.api }
        pub_apis = @publishers.select {|x|x.name == topic_name and x.type == type}.map {|x| x.api }
        proxy = XMLRPC::Client.new2(api).proxy
        code, status, ignore = proxy.publisherUpdate('/master', topic_name, pub_apis)
        if code != 1
          p 'publisherUpdate fail'
        end
        if not sub_apis
          sub_apis = []
        end
        [1, "registered", sub_apis]
      end

      @server.add_handler('unregisterPublisher') do |caller_id, topic_name, api|
        topic_name = canonicalize_name(topic_name)
        before = @publishers.length
        @publishers.delete_if {|x| x.name == topic_name and x.caller_id == caller_id}
        pub_apis = @publishers.select {|x|x.name == topic_name and x.caller_id == caller_id}.map {|x| x.api }
        proxy = XMLRPC::Client.new2(api).proxy
        begin
          code, status, ignore = proxy.publisherUpdate('/master', topic_name, pub_apis)
        rescue
          p 'do nothing'
        end
        after = @publishers.length
        [1, "deleted", before - after]
      end

      @server.add_handler('lookupNode') do |caller_id, node_name|
        pub = @publishers.select {|x| x.caller_id = node_name}
        sub = @subscribers.select {|x| x.caller_id = node_name}
        service = @services.select {|x| x.caller_id = node_name}
        if not pub.empty?
          return [1, "found", pub.first.api]
        elsif not sub.empty?
          return [1, "found", sub.first.api]
        elsif not service.empty?
          return [1, "found", service.first.api]
        end
        [0, "not found", 0]
      end
      
      @server.add_handler('getPublishedTopics') do |caller_id, subgraph|
        if subgraph == ''
          [1, "ok", @publishers.map {|x| [x.name, x.type]}]
        else
          [1, "ok", @publishers.select {|x| x.caller_id.scan(/#{subgraph}/)}
             .map {|x| [x.name, x.type]}]
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
          [1, "ok", ser.first.api]
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
            proxy = XMLRPC::Client.new2(x.api).proxy
            proxy.paramUpdate('/master', key, value)
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
        p param
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
        [1, "ok", @publishers.map {|x| [x.name, x.type]} | @subscribers.map {|x| [x.name, x.type]}]
      end
      
    end

    # start server and set default parameters
    def start
      puts "=== starting Ruby ROS master @#{@master_uri} ==="
      @parameters.push(Parameter.new('/rosversion', '1.8.6'))
      @parameters.push(Parameter.new('/rosdistro', 'fuerte'))
      
      @server.serve
      self
    end
  end
end

