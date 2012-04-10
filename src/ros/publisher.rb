require 'ros/topic'
require 'ros/tcpros/server'

module ROS

  class Publisher < Topic

    def initialize(caller_id, topic_name, topic_type, is_latched=false)
      super(caller_id, topic_name, topic_type)
      @is_latched = is_latched
    end

    def publish(message) 
      @connections.each_value do |connection|
        connection.msg_queue.push(message)
      end
    end

    def add_connection(caller_id)
      new_connection = TCPROS::Server.new(@caller_id, @topic_name, @topic_type)
      @connections[caller_id] = new_connection
      return new_connection
    end

    def get_connected_uri
      return @connections.keys
    end

  end
end
