#require 'ros/serializer'

module ROS

  class Publisher
    
#    include Serializer

    def initialize(caller_id, topic_name, topic_type, is_latched=false)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @is_latched = is_latched
      @host = "localhost"
      @connections = []
    end

    def publish(message) 
      for connection in @connections
        connection.write(serialize(@caller_id, @is_latched, @topic_name))
      end
    end
    
    attr_reader :port, :host, :topic_name, :topic_type

    def add_subscriber
      new_connection = TCPROS.new
      @connections.push(new_connection)
      return new_connection
    end

    def shutdown
      for connection in @connections
        connection.close
      end
    end

  end
end
