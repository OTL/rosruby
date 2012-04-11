require 'socket'
require 'ros/tcpros/header'

module ROS::TCPROS
  class Client
    def initialize(host, port, caller_id, topic_name, topic_type)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @port = port
      @host = host
      @msg_queue = Queue.new
      @socket = TCPSocket.open(@host, @port)
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    end
    
    def send_header
      header = Header.new
      header.push_data("callerid", @caller_id)
      header.push_data("topic", @topic_name)
      header.push_data("md5sum", @topic_type.md5sum)
      header.push_data("type", @topic_type.type)
      header.push_data("tcp_nodelay", '1')
      header.serialize(@socket)
      @socket.flush
    end

    def read_start
      @thread = Thread.start do
        loop do
          total_bytes = @socket.recv(4).unpack("V")[0]
          data = @socket.recv(total_bytes)
          msg = @topic_type.new
          msg.deserialize(data)
          @msg_queue.push(msg)
        end
      end
    end

    def read_header
      total_bytes = @socket.recv(4).unpack("V")[0]
      data = @socket.recv(total_bytes)
    end
    
    def read_msg
      msg = @topic_type.new
      total_bytes = @socket.recv(4).unpack("V")[0]
      data = @socket.recv(total_bytes)
      msg.deserialize(msg)
      return msg
    end
    
    def close
      if not @socket.closed?
        @socket.close
      end
    end

    attr_reader :port, :host
    attr_accessor :msg_queue
  end
end
