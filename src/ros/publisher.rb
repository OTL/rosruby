#require 'ros/serializer'
require 'ros/topic'
require 'ros/tcpros_server'

module ROS

  class Publisher < Topic

    def initialize(caller_id, topic_name, topic_type, is_latched=false)
      super(caller_id, topic_name, topic_type)
      @is_latched = is_latched
    end

    def publish(message) 
      @connections.each_value do |connection|
        connection.write_msg(message)
      end
    end

    def add_connection(uri)
      new_connection = TCPROS::Server.new(TCROS::Server.generate_port)
      @connections[uri] = new_connection
      return new_connection
    end
  end
end
