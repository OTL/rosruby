#require 'ros/serializer'

module ROS

  class Topic

    def initialize(caller_id, topic_name, topic_type)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @host = "localhost"
      @connections = {}
    end
    
    attr_reader :caller_id, :topic_name, :topic_type

    def shutdown
      @connections.each_value do |connection|
        connection.close
      end
    end
  end
end
