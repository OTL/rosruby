require 'socket'

module ROS
  module TCPROS
    class Server

      def initialize(port, caller_id, topic_name, topic_type)
        @@next_port = 12345
        @port = port
        @host = "localhost"
        @caller_id = caller_id
        @topic_name = topic_name
        @topic_type = topic_type
        @server = TCPServer.open(@port)
        @write_queue = Queue.new
        @msg_queue = Queue.new
        @thread = Thread.start(@server.accept) do |socket|
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
          total_bytes = socket.recv(4).unpack("V")[0]
          data = socket.recv(total_bytes)
          header = Header.new
          header.deserialize(data)
          if check_header(header)
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

      attr_accessor :msg_queue

      def check_header(header)
        return true
      end

      def send_header
        header = Header.new
        header.push_data("callerid", @caller_id)
        header.push_data("topic", @topic_name)
        header.push_data("md5sum", @topic_type.md5sum)
        header.push_data("type", @topic_type.type_string)
        header.push_data("tcp_nodelay", '1')
        p header.serialize
        @socket.write(header.serialize)
        @socket.flush
      end

      def write(data)
        @socket.write(data)
      end
      
      def close
        @server.close
        @socket.close
      end
      
      attr_reader :port, :host
      
      def self.generate_port
        @@next_port = @@next_port +1
      end
    end
  end
end
