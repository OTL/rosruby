# ros/subscriber.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
require 'ros/tcpros/message'
require 'gserver'

module ROS::TCPROS

  ##
  # This is TCPROS connection for {ROS::Publihser}
  #
  class Server < ::GServer

    include ::ROS::TCPROS::Message

    # max number of connections with {TCPROS::Client}
    MAX_CONNECTION = 100

    ##
    # @param [String] caller_id caller id of this node
    # @param [String] topic_name name of this topic
    # @param [Class] topic_type type of topic
    # @param [Hash] options :latched, :port, host, :last_published_msg
    # @option [Boolean] options :latched (false)
    # @option [Integer] options :port (0) tcp port number.
    # @option [String] options :host (GServer::DEFAULT_HOST) host name
    # @option [Message] options :last_published_msg
    def initialize(caller_id, topic_name, topic_type, options={})
      if options[:port]
        port = options[:port]
      else
        port = 0
      end
      if options[:host]
        host = options[:host]
      else
        host = GServer::DEFAULT_HOST
      end

      super(port, host, MAX_CONNECTION)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @msg_queue = Queue.new
      @is_latched = options[:latched]
      @last_published_msg = options[:last_published_msg]
      @byte_sent = 0
      @num_sent = 0
    end

    ##
    # Is this latching publisher?
    # @return [Boolean] is latched or not
    def latching?
      @is_latched
    end

    ##
    # send a message to reciever
    # @param [IO] socket socket for writing
    # @param [Class] msg msg class instance
    def publish_msg(socket, msg)
      data = write_msg(socket, msg)
      @last_published_msg = msg
      # for getBusStats
      @byte_sent += data.length
      @num_sent += 1
    end

    ##
    # this is called if a socket accept a connection.
    # This is GServer's function
    # @param [IO] socket given socket
    def serve(socket) #:nodoc:
      header = read_header(socket)
      if check_header(header)
        if header['tcp_nodelay'] == '1'
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        end
        begin
          write_header(socket, build_header)
          if latching?
            if @last_published_msg
              publish_msg(socket, @last_published_msg)
            end
          end
          loop do
            @last_published_msg = @msg_queue.pop
            publish_msg(socket, @last_published_msg)
          end
        rescue
          socket.shutdown
        end
      else
        socket.shutdown
        p "header check error: #{header}"
        raise 'header check error'
      end
    end

    attr_reader :caller_id, :msg_queue, :byte_sent, :num_sent

    # id for slave API
    # @return [String]
    attr_accessor :id
    attr_accessor :last_published_msg

    ##
    # validate header for this publisher
    # @param [Header] header for checking
    # @return [Boolean] ok(true) or not
    def check_header(header)
      header.valid?('type', @topic_type.type) and
        header.valid?('md5sum', @topic_type.md5sum)
    end

    ##
    # build {TCPROS::Header} message for this publisher.
    # It contains callerid, topic, md5sum, type, latching.
    # @return [Header] built header
    def build_header
      header = Header.new
      header["callerid"] = @caller_id
      header["topic"] = @topic_name
      header["md5sum"] = @topic_type.md5sum
      header["type"] = @topic_type.type
      if latching?
        header["latching"]  = '1'
      end
      header
    end

  end
end
