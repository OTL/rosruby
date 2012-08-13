# ros/node.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# == ROS Node
#
# user interface of ROS.
#
require 'ros/parameter_manager'
require 'ros/name'
require 'ros/graph_manager'
require 'ros/publisher'
require 'ros/subscriber'
require 'ros/parameter_subscriber'
require 'ros/service_server'
require 'ros/service_client'
require 'ros/log'
require 'ros/time'
require 'ros/rate'
require 'ros/duration'

module ROS

# main interface of rosruby.
#
# @example Sample for Publisher
#   node = ROS::Node.new('/rosruby/sample_publisher')
#   publisher = node.advertise('/chatter', Std_msgs::String)
#   sleep(1)
#   msg = Std_msgs::String.new
#   i = 0
#   while node.ok?
#     msg.data = "Hello, rosruby!: #{i}"
#     publisher.publish(msg)
#
# @example Sample for Subscriber
#   node = ROS::Node.new('/rosruby/sample_subscriber')
#   node.subscribe('/chatter', Std_msgs::String) do |msg|
#     puts "message come! = \'#{msg.data}\'"
#   end
#
#   while node.ok?
#     node.spin_once
#     sleep(1)
#   end
#
  class Node

    # for node shutdown hook
    @@shutdown_hook = []

    # Naming functions of ROS
    include Name

    ##
    # initialization of ROS node
    # get env, parse args, and start slave xmlrpc servers.
    #
    # @param [String] node_name name of this node
    # @param [Hash] options options
    # @option options [Boolean] :anonymous (false) use anonymous name if true. anonymous node generates a unique name
    def initialize(node_name, options={})
      @remappings = {}
      # @host is rewrited by ARGS[ROS_IP] or ARGS[ROS_HOSTNAME]
      @host = Socket.gethostname
      get_env
      if options[:anonymous]
        node_name = anonymous_name(node_name)
      end
      @node_name = resolve_name(node_name)
      @remappings = parse_args(ARGV)
      if not @master_uri
        raise 'ROS_MASTER_URI is nos set. please check environment variables'
      end

      @manager = GraphManager.new(@node_name, @master_uri, @host)
      @parameter = ParameterManager.new(@master_uri, @node_name, @remappings)
      if not options[:nologger]
        @logger = ::ROS::Log.new(self)
      end
      # use sim time
      ROS::Time.initialize_with_sim_or_wall(self)

      # because xmlrpc server use signal trap, after serve, it have to trap sig      trap_signals
      ObjectSpace.define_finalizer(self, proc {|id| self.shutdown})
    end

    ##
    #  Is this node running? Please use for 'while loop' and so on..
    #
    # @return [Boolean] true if node is running.
    #
    def ok?
      @manager.is_ok?
    end

    # URI of master
    # @return [String] uri string of master
    attr_reader :master_uri

    # get node URI
    # @return [String] uri of this node's api
    def slave_uri
      @manager.get_uri
    end

    # hostname of this node.
    # @return [String] host name
    attr_reader :host

    # name of this node (caller_id).
    # @return [String] name of this node (=caller_id)
    attr_reader :node_name

    ##
    # resolve the name by this node's remapping rule.
    # @param [String] name name for resolved
    # @return [String] resolved name
    #
    def resolve_name(name)
      resolve_name_with_call_id(@node_name, @ns, name, @remappings)
    end

    ##
    # get the param for key.
    # You can set default value. That is uesed when the key is not set yet.
    # @param [String] key key for search the parameters
    # @param [String, Integer, Float, Boolean] default default value
    # @return [String, Integer, Float, Boolean] parameter value for key
    #
    def get_param(key, default=nil)
      key = expand_local_name(@node_name, key)
      param = @parameter.get_param(key)
      if param
        param
      else
        default
      end
    end

    ##
    # get all parameters.
    #
    # @return [Array] all parameter list
    #
    def get_param_names
      @parameter.get_param_names
    end

    ##
    # check if the parameter server has the param for 'key'.
    # @param [String] key key for check
    # @return [Boolean] true if exits
    def has_param(key)
      @parameter.has_param(expand_local_name(@node_name, key))
    end

    ##
    # delete the parameter for 'key'
    #
    # @param [String] key key for delete
    # @return [Boolean]  true if success, false if it is not exist
    def delete_param(key)
      @parameter.delete_param(expand_local_name(@node_name, key))
    end

    ##
    # set parameter for 'key'.
    # @param [String] key key of parameter
    # @param [String, Integer, Float, Boolean] value value of parameter
    # @return [Boolean] return true if succeed
    def set_param(key, value)
      @parameter.set_param(expand_local_name(@node_name, key), value)
    end

    ##
    # start publishing the topic.
    #
    # @param [String] topic_name name of topic (string)
    # @param [Class] topic_type topic class
    # @param [Hash] options :latched, :resolve
    # @option options [Boolean] :latched (false) latched topic
    # @option options [Boolean] :resolve (true) resolve topic_name or not. This is for publish /rosout with namespaced node.
    # @return [Publisher] Publisher instance
    def advertise(topic_name, topic_type, options={})
      if options[:no_resolve]
        name = topic_name
      else
        name = resolve_name(topic_name)
      end
      publisher = Publisher.new(@node_name,
                                name,
                                topic_type,
                                options[:latched],
                                @manager.host)
      @manager.add_publisher(publisher)
      trap_signals
      publisher
    end

    ##
    # start service server.
    #
    # @param [String] service_name name of this service (string)
    # @param [Service] service_type service class
    # @param [Proc] callback service definition
    # @return [ServiceServer] ServiceServer instance
    def advertise_service(service_name, service_type, &callback)
      server = ::ROS::ServiceServer.new(@node_name,
                                        resolve_name(service_name),
                                        service_type,
                                        callback,
                                        @manager.host)
      @manager.add_service_server(server)
      trap_signals
      server
    end

    ##
    # wait until start the service.
    # @param [String] service_name name of service for waiting
    # @param [Float] timeout_sec time out seconds. default infinity.
    # @return [Boolean] true if success, false if timeout
    def wait_for_service(service_name, timeout_sec=nil)
      @manager.wait_for_service(service_name, timeout_sec)
    end

    ##
    # create service client.
    # @param [String] service_name name of this service (string)
    # @param [Class] service_type service class
    # @return [ServiceClient] created ServiceClient instance
    def service(service_name, service_type)
      ROS::ServiceClient.new(@master_uri,
                             @node_name,
                             resolve_name(service_name),
                             service_type)
    end

    ##
    # start to subscribe a topic.
    #
    # @param [String] topic_name name of topic (string)
    # @param [Class] topic_type Topic instance
    # @return [Subscriber] created Subscriber instance
    def subscribe(topic_name, topic_type, &callback)
      sub = Subscriber.new(@node_name,
                           resolve_name(topic_name),
                           topic_type,
                           callback)
      @manager.add_subscriber(sub)
      trap_signals
      sub
    end

    ##
    # subscribe to the parameter.
    #
    # @param [String] param name of parameter to subscribe
    # @param [Proc] callback callback when parameter updated
    # @return [ParameterSubscriber] created ParameterSubscriber instance
    def subscribe_parameter(param, &callback)
      sub = ParameterSubscriber.new(param, callback)
      @manager.add_parameter_subscriber(sub)
      sub
    end

    ##
    # spin once. This invoke subscription/service_server callbacks
    #
    def spin_once
      @manager.spin_once
    end

    ##
    # spin forever.
    #
    def spin
      while ok?
        spin_once
        sleep(0.01)
      end
    end

    ##
    # unregister to master and shutdown all connections.
    # @return [Node] self
    def shutdown
      if ok?
        begin
          @manager.shutdown
        rescue => message
          p message
          puts 'ignoring errors while shutdown'
        end
      end
      self
    end

    ##
    # outputs log message for INFO (INFORMATION).
    # @param [String] message message for output
    # @return [Node] self
    def loginfo(message)
      file, line, function = caller[0].split(':')
      @logger.log('INFO', message, file, function, line.to_i)
      self
    end

    ##
    # outputs log message for DEBUG
    # @param [String] message message for output
    # @return [Node] self
    def logdebug(message)
      file, line, function = caller[0].split(':')
      @logger.log('DEBUG', message, file, function, line.to_i)
      self
    end

    ##
    # outputs log message for WARN (WARING).
    #
    # @param [String] message message for output
    # @return [Node] self
    def logwarn(message)
      file, line, function = caller[0].split(':')
      @logger.log('WARN', message, file, function, line.to_i)
      self
    end

    ##
    # outputs log message for ERROR.
    #
    # @param [String] message message for output
    # @return [Node] self
    def logerror(message)
      file, line, function = caller[0].split(':')
      @logger.log('ERROR', message, file, function, line.to_i)
      self
    end

    alias_method :logerr, :logerror

    ##
    # outputs log message for FATAL.
    #
    # @param [String] message message for output
    # @return [Node] self
    def logfatal(message)
      file, line, function = caller[0].split(':')
      @logger.log('FATAL', message, file, function, line.to_i)
      self
    end

    ##
    # get all topics by this node.
    #
    # @return [Array] topic names
    def get_published_topics
      @manager.publishers.map do |pub|
        pub.topic_name
      end
    end

    private

    ##
    # parse all environment variables.
    #
    def get_env  #:nodoc:
      @master_uri = ENV['ROS_MASTER_URI']
      @ns = ENV['ROS_NAMESPACE']
      if ENV['ROS_IP']
        @host = ENV['ROS_IP']
      elsif ENV['ROS_HOSTNAME']
        @host = ENV['ROS_HOSTNAME']
      end
    end

    ##
    # converts strings if it is float and int numbers.
    # @example
    #   convert_if_needed('10') # => 10
    #   convert_if_needed('0.1') # => 0.1
    #   convert_if_needed('string') # => 'string'
    # @param [String] value string
    # @return [Float, Integer, String] return converted value.
    def convert_if_needed(value)  #:nodoc:
      if value =~ /^[+-]?\d+\.?\d*$/ # float
        value = value.to_f
      elsif value =~ /^[+-]?\d+$/ # int
        value = value.to_i
      else
        value
      end
    end

    ##
    # parse all args.
    # @param [Array] args arguments for parse
    def parse_args(args) #:nodoc:
      remapping = {}
      for arg in args
        splited = arg.split(':=')
        if splited.length == 2
          key, value = splited
          if key == '__name'
            @node_name = resolve_name(value)
          elsif key == '__ip'
            @host = value
          elsif key == '__hostname'
            @host = value
          elsif key == '__master'
            @master_uri = value
          elsif key == '__ns'
            @ns = value
          elsif key[0] == '_'[0]
            # local name remaps
            key[0] = '~'
            remapping[resolve_name(key)] = convert_if_needed(value)
          else
            # remaps
            remapping[key] = convert_if_needed(value)
          end
        end
      end
      remapping
    end

    # trap signals for safe shutdown.
    def trap_signals  #:nodoc:
      ["INT", "TERM", "HUP"].each do |signal|
        Signal.trap(signal) do
          ROS::Node.shutdown_all_nodes
        end
      end
    end

    def self.add_shutdown_hook(proc)
      @@shutdown_hook.push(proc)
    end

    # shutdown all nodes.
    def self.shutdown_all_nodes
      GraphManager.shutdown_all
      @@shutdown_hook.each {|obj| obj.call}
    end

  end
end
