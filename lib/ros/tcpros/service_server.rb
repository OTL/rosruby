# ros/tcpros/service_server.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
require 'ros/tcpros/message'
require 'gserver'

module ROS::TCPROS

  ##
  # TCPROS protocol Service Server
  #
  class ServiceServer < ::GServer

    ##
    # max number of connection with clients
    #
    MAX_CONNECTION = 100

    include ::ROS::TCPROS::Message

    ##
    # @param [String] caller_id caller_id of this node
    # @param [String] service_name name of this service
    # @param [Class] service_type class of this service message
    # @param [Proc] callback of this service
    # @param [Hash] options options
    # @option options [Integer] port port number (default: 0)
    # @option options [host] host host name (defualt: Socket.gethostname)
    def initialize(caller_id, service_name, service_type, callback,
                   options={})
      if options[:host]
        host = options[:host]
      else
        host = Socket.gethostname
      end
      if options[:port]
        port = options[:port]
      else
        port = 0
      end

      super(port, host, MAX_CONNECTION)
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
      @callback = callback
      @byte_received = 0
      @byte_sent = 0
    end

    ##
    # message must send 1 byte for service call result (success)
    # @param [IO] socket
    def send_ok_byte(socket)
      socket.write([1].pack('c'))
    end

    ##
    # message must send 1 byte for service call result (fail)
    # @param [IO] socket
    def send_ng_byte(socket)
      socket.write([0].pack('c'))
    end

    ##
    # main loop of this connection.
    # read data and do callback.
    # @param [IO] socket
    # @return [Boolean] result of callback
    def read_and_callback(socket)
      request = @service_type.request_class.new
      response = @service_type.response_class.new
      data = read_all(socket)
      @byte_received += data.length
      request.deserialize(data)
      result = @callback.call(request, response)
      if result
        send_ok_byte(socket)
        data = write_msg(socket, response)
        @byte_sent += data.length
      else
        send_ng_byte(socket)
        write_header(socket, build_header)
        # write some message
      end
      result
    end

    ##
    # this is called by socket accept
    # @param [IO] socket given socket
    def serve(socket)
      header = read_header(socket)
      # not documented protocol?
      if header['probe'] == '1'
        write_header(socket, build_header)
      elsif check_header(header)
        write_header(socket, build_header)
        read_and_callback(socket)
        if header['persistent'] == '1'
          loop do
            read_and_callback(socket)
          end
        end
      else
        socket.close
        raise 'header check error'
      end
    end

    ##
    # check header.
    # check md5sum only.
    # @param [Header] header header for checking
    # @return [Boolean] check result (true means ok)
    def check_header(header)
      header.valid?('md5sum', @service_type.md5sum)
    end

    ##
    # build header message for service server.
    # It contains callerid, type, md5sum.
    # @return [Header] built header
    def build_header
      header = Header.new
      header["callerid"] = @caller_id
      header['type'] = @service_type.type
      header['md5sum'] = @service_type.md5sum
      header
    end

    # received data amout for slave api
    # @return [Integer] byte received
    attr_reader :byte_received

    # sent data amout for slave api
    # @return [Integer] byte sent
    attr_reader :byte_sent

  end
end
