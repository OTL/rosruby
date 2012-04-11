module ROS

  class Service

    def initialize(caller_id, service_name, service_type)
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
      @host = "localhost"
    end
    
    attr_reader :caller_id, :service_name, :service_type

    def get_connected_uri
      return @connections.keys
    end

  end
end
