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
  # {Node#advertise_service} return a instance of this class.
  # Service can be shutdown by {ServiceServer#shutdown}.
  # This class uses {TCPROS::ServiceServer} for data transfer.
  # @example
  #   node = ROS::Node.new('/rosruby/sample_service_server')
  #   server = node.advertise_service('/add_two_ints', Roscpp_tutorials::TwoInts) do |req, res|
  #     res.sum = req.a + req.b
  #     node.loginfo("a=#{req.a}, b=#{req.b}")
  #     node.loginfo("  sum = #{res.sum}")
  #     true
  #   end
  #   while node.ok?
  #     sleep (1.0)
  #   end
  class ServiceServer < Service

    # @param [String] caller_id caller id of this node
    # @param [String] service_name name of this service (String)
    # @param [Class] service_type class of srv
    # @param [Proc] callback callback object of this service.
    # @param [String] host host name
    def initialize(caller_id, service_name, service_type, callback, host)
      super(caller_id, service_name, service_type)
      @callback = callback
      @server = TCPROS::ServiceServer.new(@caller_id,
                                          @service_name,
                                          @service_type,
                                          self,
                                          :host => host)
      @server.start
      @num_request = 0
    end

    ##
    # execute the service callback.
    # User should not call this directly.
    # @param [Message] request srv Request instance
    # @param [Message] response srv Response instance
    # @return [Boolean] callback result
    def call(request, response)
      @num_request += 1
      @callback.call(request, response)
    end

    # URI of this service (rosrpc://**)
    # @return [String] rosrpc service uri
    def service_uri
      'rosrpc://' + @server.host + ':' + @server.port.to_s
    end

    ##
    # user should not call this method.
    # Please use shutdown method.
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
    # @param [GraphManager] manager set as manager
    def set_manager(manager) #:nodoc:
      @manager = manager
    end

    # @return [Array] connection data
    def get_connection_data
      [@num_request, @server.byte_received, @server.byte_sent]
    end

    # @return [Integer] how many times this service called
    attr_reader :num_request
  end
end
