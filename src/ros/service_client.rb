require 'ros/service'
require 'ros/tcpros/service_client'
require 'uri'

module ROS
  class ServiceClient < Service
    def initialize(master_uri, caller_id, service_name, service_type, persistent=false)
      super(caller_id, service_name, service_type)
      @master_uri = master_uri
      @persistent = persistent
    end

    def get_host_port_from_uri(uri)
      uri_data = URI.split(uri)
      [uri_data[2], uri_data[3]]
    end

    def call(srv_request, srv_response)
      if @persistent and @connection
        # not connect
      else
        master = XMLRPC::Client.new2(@master_uri)
        code, message, uri = master.call('lookupService',
                                         @caller_id,
                                         @service_name)
        case code
        when 1
          host, port = get_host_port_from_uri(uri)
          @connection = TCPROS::ServiceClient.new(host, port, @caller_id, @service_name, @service_type, @persistent)
          return @connection.call(srv_request, srv_response)
        when -1
          raise "master error ${message}"
        else
          puts "fail to lookup"
          nil
        end
      end
    end

    def shutdown
      @connection.close
    end

  end
end
      
