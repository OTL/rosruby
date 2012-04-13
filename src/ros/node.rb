require 'ros/parameter_manager'
require 'ros/name'
require 'ros/topic_manager'
require 'ros/publisher'
require 'ros/subscriber'
require 'ros/service_server'
require 'ros/service_client'
require 'ros/log'

module ROS
  class Node

    include Name

    def initialize(node_name)
      get_env
      @node_name = resolve_name(node_name)
      parse_args(ARGV)
      if not @master_uri
        raise 'ROS_MASTER_URI is nos set. please check environment variables'
      end

      @manager = TopicManager.new(@node_name, self)
      @parameter = ParameterManager.new(@master_uri, @node_name, @remappings)
      @is_ok = true
      # because xmlrpc server use signal trap, after serve, it have to trap signal
      trap_signals

      @logger = ::ROS::Log.new(self)
    end

    def ok?
      return @is_ok
    end

    attr_reader :master_uri, :host, :node_name

    def resolve_name(name)
      resolve_name_with_call_id(@node_name, @ns, name)
    end

    def get_param(key)
      key = expand_local_name(@node_name, key)
      if @remappings[key]
        return @remappings[key]
      else
        @parameter.get_param(key)
      end
    end

    def get_param_names
      @parameter.get_param_names
    end

    def has_param(key)
      @parameter.has_param(key)
    end

    def delete_param(key)
      @parameter.delete_param(key)
    end

    def set_param(key, value)
      @parameter.set_param(expand_local_name(@node_name, key), value)
    end

    def advertise(topic_name, topic_type, latched=false, resolve=true)
      if resolve
        name = resolve_name(topic_name)
      else
        name = topic_name
      end
      @manager.add_publisher(Publisher.new(@node_name,
                                           name,
                                           topic_type,
                                           latched,
                                           @manager.host))
    end

    def advertise_service(service_name, service_type, callback)
      @manager.add_service_server(::ROS::ServiceServer.new(@node_name,
                                                           resolve_name(service_name),
                                                           service_type,
                                                           callback))
    end

    def wait_for_service(service_name, timeout_sec=nil)
      @manager.wait_for_service(service_name, timeout_sec)
    end

    def service(service_name, service_type)
      ROS::ServiceClient.new(@master_uri,
                             @node_name,
                             resolve_name(service_name),
                             service_type)
    end

    def subscribe(topic_name, topic_type, &callback)
      @manager.add_subscriber(Subscriber.new(@node_name,
                                             resolve_name(topic_name),
                                             topic_type,
                                             callback))
    end

    def spin_once
      @manager.spin_once
    end

    def shutdown
      @is_ok = false
      @manager.shutdown
    end

    def loginfo(message)
      file, line, function = caller[0].split(':')
      @logger.log('INFO', message, file, function, line.to_i)
    end

    def logdebug(message)
      file, line, function = caller[0].split(':')
      @logger.log('DEBUG', message, file, function, line.to_i)
    end

    def logwarn(message)
      file, line, function = caller[0].split(':')
      @logger.log('WARN', message, file, function, line.to_i)
    end

    def logerror(message)
      file, line, function = caller[0].split(':')
      @logger.log('ERROR', message, file, function, line.to_i)
    end

    alias_method :logerr, :logerror

    def logfatal(message)
      file, line, function = caller[0].split(':')
      @logger.log('FATAL', message, file, function, line.to_i)
    end

    def get_published_topics
      @manager.publishers.map do |pub|
        pub.topic_name
      end
    end

    private

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
            remapping[resolve_name(key)] = convert_if_needded(value)
          else
            # remaps
            remapping[key] = convert_if_needded(value)
          end
        end
      end
      set_remappings(remapping)
    end

    def trap_signals
      [:INT, :TERM, :HUP].each do |signal|
        Signal.trap(signal,
                    proc do
                      if @is_ok
                        puts 'shutdown by signal'
                        shutdown
                      end
                    end)
      end
    end
  end
end
