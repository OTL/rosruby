require 'ros/service'
require 'ros/tcpros/server'

module ROS
  class ServiceClient < Service
    
    def add_connection(uri)
      new_connection = TCPROS::Server.new(@caller_id, @service_name, @service_type)
      @connections[caller_id] = new_connection
      return new_connection
    end
  end
end
      
