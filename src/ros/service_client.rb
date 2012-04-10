require 'ros/service'
require 'ros/tcpros/service_client'
require 'uri'

module ROS
  class ServiceClient < Service
    def initialize(caller_id, service_name, service_type, persistent=false)
      super(caller_id, service_name, service_type)
      @persistent = persistent
    end

    def call(srv_request, srv_response)
      @connection.call(srv_request, srv_response)
    end

    def connect(uri)
      uri_data = URI.split(uri)
      host = uri_data[2]
      port = uri_data[3]
      @connection = TCPROS::ServiceClient.new(host, port, @caller_id, @service_name, @service_type, @persistent)
    end
  end
end
      
