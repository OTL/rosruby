require 'ros/service'
require 'ros/tcpros/service_server'

module ROS
  class ServiceServer < Service

    def initialize(caller_id, service_name, service_type, callback)
      super(caller_id, service_name, service_type)
      @callback = callback
      @server = TCPROS::ServiceServer.new(@caller_id,
                                          @service_name,
                                          @service_type,
                                          self)
      @server.start
      @num_request = 0
    end

    def call(request, response)
      @num_request += 1
      @callback.call(request, response)
    end

    def service_uri
      'rosrpc://' + @server.host + ':' + @server.port.to_s
    end

    def shutdown
      @server.close
    end

    def get_connection_data
      [@num_request, @server.byte_received, @server.byte_sent]
    end

    attr_reader :num_request
  end
end
