require 'socket'
require 'ros/tcpros/header'

module ROS::TCPROS
  class ServiceClient
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
    
    def send_header
      header = Header.new
      header.push_data("callerid", @caller_id)
      header.push_data("service", @service_name)
      header.push_data("md5sum", @service_type.md5sum)
      header.push_data("type", @service_type.type_string)
      if @persistent
        header.push_data("persistent", '1')
      end
      @socket.write(header.serialize)
      @socket.flush
    end

    def call(srv_request, srv_response)
      send_header
      header = read_header
      if check_header(header)
        @socket.write(srv_request.serialize)
        @socket.flush
        ok_byte = @socket.recv(1).unpack('c')[0]
        if ok_byte == 1
          data = read_response
          srv_response.deserialize(data)
          return true
        end
      end
    end

    def check_header(header)
      if header['md5sum'] == @service_type.md5sum
        return true
      end
      return false
    end

    def read_header
      total_bytes = @socket.recv(4).unpack("V")[0]
      data = @socket.recv(total_bytes)
      header = ::ROS::TCPROS::Header.new
      header.deserialize(data)
      return header
    end
    
    def read_response
      total_bytes = @socket.recv(4).unpack("V")[0]
      data = @socket.recv(total_bytes)
      return data
    end
    
    def close
      @socket.close
    end

    attr_reader :port, :host
  end
end
