require 'ros/param'
require 'ros/name'
require 'ros/topic_manager'
require 'ros/publisher'

module ROS

  class Node
    
    include Param
    include Name

    def initialize(node_name)
      @node_name = node_name
      @manager = TopicManager.new(@node_name)
    end
    
    def resolve_name(name)
      resolve_name_with_call_id(@node_name, name)
    end

    def get_param(key)
      get_param_with_caller_id(@node_name, resolve_name(key))
    end
    
    def set_param(key, value)
      set_param_with_caller_id(@node_name, resolve_name(key), value)
    end

    def advertise(topic_name, topic_type)
      @manager.add_publisher(Publisher.new(@node_name, topic_name, topic_type))
    end

    def shutdown
      @manager.shutdown
    end
  end
  
end
