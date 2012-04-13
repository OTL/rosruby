require 'socket'
require 'ros/tcpros/header'
require 'ros/tcpros/message'

module ROS::TCPROS
  class ServiceClient

    include ::ROS::TCPROS::Message

    def initialize(host, port, caller_id, service_name, service_type, persistent)
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
      @port = port
      @host = host
      @socket = TCPSocket.open(@host, @port)
      @persistent = persistent
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    end
    
    def build_header
      header = Header.new
      header.push_data("callerid", @caller_id)
      header.push_data("service", @service_name)
      header.push_data("md5sum", @service_type.md5sum)
      header.push_data("type", @service_type.type)
      if @persistent
        header.push_data("persistent", '1')
      end
    end

    def call(srv_request, srv_response)
      write_header(@socket, build_header)
      if check_header(read_header)
        write_msg(srv_request, @socket)
        @socket.flush
        ok_byte = read_ok_byte
        if ok_byte == 1
          srv_response.deserialize(read_all(@socket))
          return true
        end
        false
      end
      false
    end

    def read_ok_byte
      @socket.recv(1).unpack('c')[0]
    end

    def check_header(header)
      header.valid?('md5sum', @service_type.md5sum)
    end
    
    def shutdown
      @socket.close
    end

    attr_reader :port, :host

  end
end
