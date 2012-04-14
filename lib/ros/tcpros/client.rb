#  ros/tcpros/client.rb
#
# $Revision: $
# $Id:$
# $Date:$
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'socket'
require 'ros/tcpros/message'
require 'ros/tcpros/header'

module ROS::TCPROS
  class Client

    include ::ROS::TCPROS::Message

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
    end

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
    attr_accessor :id
  end
end
