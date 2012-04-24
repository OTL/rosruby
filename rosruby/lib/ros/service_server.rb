# ros/service_server.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# server of ROS Service.
# This uses ROS::TCPROS::ServiceServer for data transfer.
#
require 'ros/service'
require 'ros/tcpros/service_server'

module ROS

  # server of ROS Service.
  # This uses ROS::TCPROS::ServiceServer for data transfer.
  class ServiceServer < Service

    # [+caller_id+] caller id of this node
    # [+service_name+] name of this service (String)
    # [+service_type+] class of srv
    # [+callback+] callback object of this service.
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
    # [+request+] srv Request instance
    # [+response+] srv Response instance
    # [+return+] callback result (bool)
    def call(request, response)
      @num_request += 1
      @callback.call(request, response)
    end

    # URI of this service (rosrpc://**)
    # [+return+] rosrpc service uri
    def service_uri
      'rosrpc://' + @server.host + ':' + @server.port.to_s
    end

    ##
    # user should not call this method. use shutdown method
    #
    def close #:nodoc:
      @server.shutdown
    end

    ##
    # shutdown the service connection
    #
    def shutdown
      @manager.shutdow_service_server(self)
    end

    # set GraphManager for shutdown
    # [+manager+] GraphManager
    def set_manager(manager) #:nodoc:
      @manager = manager
    end

    # [+return+] connection data
    def get_connection_data
      [@num_request, @server.byte_received, @server.byte_sent]
    end

    # how many times this service called
    attr_reader :num_request
  end
end
