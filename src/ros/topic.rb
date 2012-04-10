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

    def get_connected_uri
      return @connections.keys
    end

    def drop_connection(uri)
      @connections[uri].close
    end

    def has_connection_with?(uri)
      return @connections[uri]
    end

  end
end
