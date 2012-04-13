require 'ros/tcpros/message'
require 'gserver'

module ROS::TCPROS

  class Server < ::GServer

    include ::ROS::TCPROS::Message

    MAX_CONNECTION = 100

    def initialize(caller_id, topic_name, topic_type, is_latched,
                   port=0, host=GServer::DEFAULT_HOST)
      super(port, host, MAX_CONNECTION)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @msg_queue = Queue.new
      @is_latched = is_latched
      @byte_sent = 0
      @num_sent = 0
      @last_published_msg = nil
    end

    def latching?
      @is_latched
    end

    def publish_msg(socket, msg)
      data = write_msg(socket, msg)
      @last_published_msg = msg
      # for getBusStats
      @byte_sent += data.length
      @num_sent += 1
    end

    def serve(socket)
      header = read_header(socket)
      if check_header(header)
        if header['tcp_nodelay'] == '1'
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        end
        begin
          write_header(socket, build_header)
          if latching?
            publish_msg(socket, @last_published_msg)
          end
          loop do
            publish_msg(socket, @msg_queue.pop)
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
    attr_accessor :id

    def check_header(header)
      header.valid?('type', @topic_type.type) and
        header.valid?('md5sum', @topic_type.md5sum)
    end

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
