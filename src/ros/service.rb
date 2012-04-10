module ROS

  class Service

    def initialize(caller_id, service_name, service_type)
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
      @host = "localhost"
      @connections = {}
    end
    
    attr_reader :caller_id, :service_name, :service_type

    def shutdown
      @connections.each_value do |connection|
        connection.close
      end
    end

    def get_connected_uri
      return @connections.keys
    end

  end
end
