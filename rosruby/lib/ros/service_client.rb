# ros/service_client.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'ros/service'
require 'ros/tcpros/service_client'
require 'uri'

module ROS


  # This is an interface of ROS Service.
  # {Node#service} returns {ServiceClient} instance.
  # @example
  #   node = ROS::Node.new('/rosruby/sample_service_client')
  #   if node.wait_for_service('/add_two_ints', 1)
  #     service = node.service('/add_two_ints', Roscpp_tutorials::TwoInts)
  #     req = Roscpp_tutorials::TwoInts.request_class.new
  #     res = Roscpp_tutorials::TwoInts.response_class.new
  #     req.a = 1
  #     req.b = 2
  #     if service.call(req, res)
  #        p res.sum
  #      end
  #    end
  class ServiceClient < Service

    # @param [String] master_uri URI of ROS Master
    # @param [String] caller_id caller id of this node
    # @param [String] service_name name of service
    # @param [Class] service_type class of srv
    # @param [Boolean] persistent use persistent connection with server or not.
    def initialize(master_uri, caller_id, service_name, service_type, persistent=false)
      super(caller_id, service_name, service_type)
      @master_uri = master_uri
      @persistent = persistent
    end

    ##
    # get hostname and port from uri
    # @param [String] uri decompose uri string to host and port
    # @return [Array<String, Integer>] [host, port]
    def get_host_port_from_uri(uri) #:nodoc:
      uri_data = URI.split(uri)
      [uri_data[2], uri_data[3]]
    end

    # call service
    # @param [Message] srv_request srv Request instance
    # @param [Message] srv_response srv Response instance
    # @return [Boolean] result of call
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

    # shutdown this service client
    def shutdown
      @connection.close
    end

  end
end
