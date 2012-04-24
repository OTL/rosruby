#  ros/tcpros/client.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'socket'
require 'ros/tcpros/message'
require 'ros/tcpros/header'

module ROS::TCPROS

  ##
  # rosrpc's client for subscriber
  #
  class Client

    include ::ROS::TCPROS::Message

    ##
    # [+host+] host name (String)
    # [+port+] port number
    # [+caller_id+] caller id of this node
    # [+topic_name+] name of this topic (String)
    # [+topic_type+] type of topic (class)
    # [+target_uri+] URI of connection target
    # [+tcp_no_delay+] use tcp no delay option or not (Bool)
    def initialize(host, port,
                   caller_id, topic_name, topic_type, target_uri,
                   tcp_no_delay)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @port = port
      @host = host
      @target_uri = target_uri
      @msg_queue = Queue.new
      @socket = TCPSocket.open(@host, @port)
      @tcp_no_delay = tcp_no_delay
      if tcp_no_delay
        @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end
      @byte_received = 0
      @is_running = true
    end

    ##
    # build header data for subscription
    # [+return+] built header ROS::TCPROS::Header
    def build_header
      header = Header.new
      header.push_data("callerid", @caller_id)
      header.push_data("topic", @topic_name)
      header.push_data("md5sum", @topic_type.md5sum)
      header.push_data("type", @topic_type.type)
      if @tcp_no_delay
        header.push_data("tcp_nodelay", '1')
      else
        header.push_data("tcp_nodelay", '0')
      end
      header
    end

    ##
    # start recieving data.
    # The received messages are pushed into a message queue.
    def start
      write_header(@socket, build_header)
      read_header(@socket)
      @thread = Thread.start do
        while @is_running
          data = read_all(@socket)
          msg = @topic_type.new
          msg.deserialize(data)
          @byte_received += data.length
          @msg_queue.push(msg)
        end
      end
    end

    ##
    # close the connection.
    # kill the thread if it is not response.
    def shutdown
      @is_running = false
      if not @thread.join(0.1)
        Thread::kill(@thread)
      end
      if not @socket.closed?
        @socket.close
      end
    end

    attr_reader :port, :host, :msg_queue, :byte_received, :target_uri

    # id for slave API
    attr_accessor :id
  end
end
