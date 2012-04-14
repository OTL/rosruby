# ros/service_server.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# =ROS Service Server
# server of ROS Service.
# This uses ROS::TCPROS::ServiceServer for data transfer.
#
require 'ros/service'
require 'ros/tcpros/service_server'

module ROS

  # server of ROS Service.
  # This uses ROS::TCPROS::ServiceServer for data transfer.
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

    ##
    # execute the service callback
    # @return callback result (bool)
    def call(request, response)
      @num_request += 1
      @callback.call(request, response)
    end

    ##
    # @return rosrpc service uri
    #
    def service_uri
      'rosrpc://' + @server.host + ':' + @server.port.to_s
    end

    ##
    # shutdown the service connection
    #
    def shutdown
      @server.shutdown
    end

    def get_connection_data
      [@num_request, @server.byte_received, @server.byte_sent]
    end

    # how many times this service called
    attr_reader :num_request
  end
end
