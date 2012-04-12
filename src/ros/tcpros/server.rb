require 'stringio'
require 'socket'
require 'thread'
require 'ros/tcpros'
require 'ros/tcpros/message'

module ROS::TCPROS
  class Server

    include ::ROS::TCPROS::Message

    def initialize(caller_id, topic_name, topic_type, port=0)
      @host = "localhost"
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @server = TCPServer.open(port)
      saddr = @server.getsockname
      @port = Socket.unpack_sockaddr_in(saddr)[0]
      @write_queue = Queue.new
      @msg_queue = Queue.new
    end

    def start
      @accept_thread = Thread.new do
        while socket = @server.accept
        @thread = Thread.new do
          total_bytes = socket.recv(4).unpack("V")[0]
          data = socket.recv(total_bytes)
          header = Header.new
          header.deserialize(data)
          if check_header(header)
            if header['tcp_nodelay'] == '1'
              socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
            end
            send_header(socket)
            loop do
              write_msg(@msg_queue.pop, socket)
            end
          else
            socket.close
            p 'header check error'
            raise 'header check error'
          end
        end
      end
      end
    end

    attr_reader :msg_queue

    def check_header(header)
      if header['type'] == @topic_type.type and header['md5sum'] == @topic_type.md5sum
        return true
      end
      return false
    end

    def send_header (socket)
      header = Header.new
      header.push_data("callerid", @caller_id)
      header.push_data("topic", @topic_name)
      header.push_data("md5sum", @topic_type.md5sum)
      header.push_data("type", @topic_type.type)
      header.push_data("tcp_nodelay", '1')
      header.serialize(socket)
      socket.flush
    end
    
    def close
      @server.close
    end
    
    attr_reader :port, :host
    
  end
end
