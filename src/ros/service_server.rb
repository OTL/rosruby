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
                                          @callback)
      @server.start
    end

    def service_uri
      'rosrpc://' + @server.host + ':' + @server.port.to_s
    end

  end
end
