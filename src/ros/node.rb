require 'ros/parameter_manager'
require 'ros/name'
require 'ros/topic_manager'
require 'ros/publisher'
require 'ros/subscriber'
require 'ros/service_server'
require 'ros/service_client'

module ROS
  class Node
    include Name

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
          else
            # remaps
            remapping[key] = value
          end
        end
      end
      set_remappings(remapping)
    end

    def initialize(node_name)
      @master_uri = ENV['ROS_MASTER_URI']
      @ns = ENV['ROS_NAMESPACE']
      if ENV['ROS_IP']
        @host = ENV['ROS_IP']
      elsif ENV['ROS_HOSTNAME']
        @host = ENV['ROS_HOSTNAME']
      end
      @node_name = resolve_name(node_name)
      parse_args(ARGV)
      if not @master_uri
        raise 'ROS_MASTER_URI is nos set. please check environment variables'
      end

      @manager = TopicManager.new(@node_name, self)
      @parameter = ParameterManager.new(@node_name, self)
      @is_ok = true
      # because xmlrpc server use signal trap, after serve, it have to trap signal
      [:INT, :TERM, :HUP].each do |signal|
        Signal.trap(signal, proc{if @is_ok
                                   p 'shutdown by signal'
                                   shutdown
                                 end})
      end
    end

    def ok?
      return @is_ok
    end

    attr_reader :master_uri, :host

    def resolve_name(name)
      resolve_name_with_call_id(@node_name, @ns, name)
    end

    def get_param(key)
      @parameter.get_param(resolve_name(key))
    end

    def set_param(key, value)
      @parameter.set_param(resolve_name(key), value)
    end

    def advertise(topic_name, topic_type)
      @manager.add_publisher(Publisher.new(@node_name,
                                           resolve_name(topic_name),
                                           topic_type))
    end

    def advertise_service(service_name, service_type, callback)
      @manager.add_service_server(::ROS::ServiceServer.new(@node_name,
                                                           resolve_name(service_name,
                                                           service_type,
                                                           callback)))
    end

    def service(service_name, service_type)
      @manager.add_service_client(::ROS::ServiceClient.new(@node_name,
                                                           resolve_name(service_name),
                                                           service_type))
    end

    def subscribe(topic_name, topic_type, callback)
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
  end
end
