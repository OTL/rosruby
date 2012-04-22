# ros/node.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# = ROS Node
#
# user interface of ROS.
#
require 'ros/parameter_manager'
require 'ros/name'
require 'ros/graph_manager'
require 'ros/publisher'
require 'ros/subscriber'
require 'ros/service_server'
require 'ros/service_client'
require 'ros/log'
require 'ros/time'
require 'ros/duration'

module ROS

=begin rdoc

= ROS Node
  main interface of rosruby.
  This class has many inner informations.
  It may be better to use pimpl pattern.

== Sample for Publisher

  node = ROS::Node.new('/rosruby/sample_publisher')
  publisher = node.advertise('/chatter', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new
  i = 0
  while node.ok?
    msg.data = "Hello, rosruby!: #{i}"
    publisher.publish(msg)

== Sample for Subscriber

  node = ROS::Node.new('/rosruby/sample_subscriber')
  node.subscribe('/chatter', Std_msgs::String) do |msg|
    puts "message come! = \'#{msg.data}\'"
  end

  while node.ok?
    node.spin_once
    sleep(1)
  end
=end


  class Node

    # Naming functions of ROS
    include Name

    ##
    # current running all nodes. This is for shutdown all nodes
    #
    @@all_nodes = []

    ##
    # initialization of ROS node
    # get env, parse args, and start slave xmlrpc servers.
    #
    # [+node_name+] name of this node
    # [+anonymous+] anonymous node generates a unique name
    def initialize(node_name, anonymous=nil)
      @remappings = {}
      get_env
      if anonymous
        node_name = anonymous_name(node_name)
      end
      @node_name = resolve_name(node_name)
      @remappings = parse_args(ARGV)
      if not @master_uri
        raise 'ROS_MASTER_URI is nos set. please check environment variables'
      end

      @manager = GraphManager.new(@node_name, self)
      @parameter = ParameterManager.new(@master_uri, @node_name, @remappings)
      @is_ok = true
      # because xmlrpc server use signal trap, after serve, it have to trap signal
      @@all_nodes.push(self)
      @logger = ::ROS::Log.new(self)
      trap_signals
      ObjectSpace.define_finalizer(self, proc {|id| self.shutdown})
    end

    ##
    #  Is this node running? Please use for 'while loop' and so on..
    #
    # [+return+] true if node is running.
    #
    def ok?
      return @is_ok
    end

    # URI of master
    attr_reader :master_uri

    # hostname of this node
    attr_reader :host

    # name of this node (caller_id)
    attr_reader :node_name

    ##
    # resolve the name by this node's remapping rule
    #
    # [+return+] resolved name
    #
    def resolve_name(name)
      resolve_name_with_call_id(@node_name, @ns, name, @remappings)
    end

    ##
    # get the param for key
    #
    # [+key+] key for search the parameters
    # [+return+] parameter value for key
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
    # get all parameters
    #
    # [+return+] all parameter list
    #
    def get_param_names
      @parameter.get_param_names
    end

    ##
    # check if the parameter server has the param for 'key'
    #
    def has_param(key)
      @parameter.has_param(key)
    end

    ##
    # delete the parameter for 'key'
    #
    # [+key+] key for delete
    # [return] true if success, false if it is not exist
    def delete_param(key)
      @parameter.delete_param(key)
    end

    ##
    # set parameter for 'key'
    # [key] key of parameter
    # [value] value of parameter
    # [return] true if succeed
    def set_param(key, value)
      @parameter.set_param(expand_local_name(@node_name, key), value)
    end

    ##
    # start publishing the topic
    #
    # [+topic_name+] name of topic (string)
    # [+topic_type+] topic class
    # [+latched+] is this latched topic?
    # [+resolve+] if true, use resolve_name for this topic_name
    def advertise(topic_name, topic_type, latched=false, resolve=true)
      if resolve
        name = resolve_name(topic_name)
      else
        name = topic_name
      end
      publisher = Publisher.new(@node_name,
                                name,
                                topic_type,
                                latched,
                                @manager.host)
      @manager.add_publisher(publisher)
      trap_signals
      publisher
    end

    ##
    # start service
    #
    # [+service_name+] name of this service (string)
    # [+service_type+] service class
    # [+callback+] service definition
    def advertise_service(service_name, service_type, &callback)
      server = ::ROS::ServiceServer.new(@node_name,
                                        resolve_name(service_name),
                                        service_type,
                                        callback)
      @manager.add_service_server(server)
      trap_signals
      server
    end

    ##
    # wait until start the service
    # [+service_name+] name of service for waiting
    # [+timeout_sec+] time out seconds. default infinity.
    #
    def wait_for_service(service_name, timeout_sec=nil)
      @manager.wait_for_service(service_name, timeout_sec)
    end

    ##
    # create service client
    # [+service_name+] name of this service (string)
    # [+service_type+] service class
    def service(service_name, service_type)
      ROS::ServiceClient.new(@master_uri,
                             @node_name,
                             resolve_name(service_name),
                             service_type)
    end

    ##
    # start to subscribe
    #
    # [+topic_name+] name of topic (string)
    # [+topic_type+] topic class
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
    # spin once. This invoke subscription/service_server callbacks
    #
    def spin_once
      @manager.spin_once
    end

    ##
    # spin forever
    #
    def spin
      while ok?
        spin_once
        sleep(0.01)
      end
    end

    ##
    # unregister to master and shutdown all connections
    #
    def shutdown
      if @is_ok
        @is_ok = false
        @manager.shutdown
        @@all_nodes.delete(self)
      end
      self
    end

    ##
    # outputs log message for INFO (INFORMATION)
    #
    def loginfo(message)
      file, line, function = caller[0].split(':')
      @logger.log('INFO', message, file, function, line.to_i)
    end

    ##
    # outputs log message for DEBUG
    #
    def logdebug(message)
      file, line, function = caller[0].split(':')
      @logger.log('DEBUG', message, file, function, line.to_i)
    end

    ##
    # outputs log message for WARN (WARING)
    #
    def logwarn(message)
      file, line, function = caller[0].split(':')
      @logger.log('WARN', message, file, function, line.to_i)
    end

    ##
    # outputs log message for ERROR
    #
    def logerror(message)
      file, line, function = caller[0].split(':')
      @logger.log('ERROR', message, file, function, line.to_i)
    end

    alias_method :logerr, :logerror

    ##
    # outputs log message for FATAL
    #
    def logfatal(message)
      file, line, function = caller[0].split(':')
      @logger.log('FATAL', message, file, function, line.to_i)
    end

    ##
    # get all topics by this node
    #
    # [+return+] topic names
    def get_published_topics
      @manager.publishers.map do |pub|
        pub.topic_name
      end
    end

    private

    ##
    # parse all environment variables
    #
    def get_env
      @master_uri = ENV['ROS_MASTER_URI']
      @ns = ENV['ROS_NAMESPACE']
      if ENV['ROS_IP']
        @host = ENV['ROS_IP']
      elsif ENV['ROS_HOSTNAME']
        @host = ENV['ROS_HOSTNAME']
      end
    end

    def convert_if_needed(value)
      if value =~ /^[+-]?\d+\.?\d*$/ # float
        value = value.to_f
      elsif value =~ /^[+-]?\d+$/ # int
        value = value.to_i
      else
        value
      end
    end

    ##
    # parse all args
    def parse_args(args)
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

    def trap_signals
#      [:INT, :TERM, :HUP].each do |signal|
      ["INT", "TERM", "HUP"].each do |signal|
        Signal.trap(signal) do
          @@all_nodes.each do |node|
            if node.ok?
              puts 'shutdown by signal'
              node.shutdown
            end
          end
        end
      end
    end
  end
end
