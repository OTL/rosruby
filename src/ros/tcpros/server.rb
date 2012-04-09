require 'socket'
require 'thread'
require 'ros/tcpros'

module ROS::TCPROS
  class Server

    def initialize(caller_id, topic_name, topic_type, port=0)
      @@next_port = 12345
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
        socket = @server.accept
        @thread = Thread.new do
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
          total_bytes = socket.recv(4).unpack("V")[0]
          data = socket.recv(total_bytes)
          header = Header.new
          header.deserialize(data)
          if check_header(header)
            send_header(socket)
            loop do
              msg = @msg_queue.pop
              socket.write(msg.serialize)
            end
          else
            socket.close
            raise 'header check error'
          end
        end
      end
    end

    attr_accessor :msg_queue

    def check_header(header)
      return true
    end

    def send_header (socket)
      header = Header.new
      header.push_data("callerid", @caller_id)
      header.push_data("topic", @topic_name)
      header.push_data("md5sum", @topic_type.md5sum)
      header.push_data("type", @topic_type.type_string)
      header.push_data("tcp_nodelay", '1')
      socket.write(header.serialize)
      socket.flush
    end
    
    def close
      @server.close
    end
    
    attr_reader :port, :host
    
  end
end
