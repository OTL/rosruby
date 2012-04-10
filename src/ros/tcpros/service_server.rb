require 'socket'
require 'thread'
require 'ros/tcpros'

module ROS::TCPROS
  class ServiceServer

    def initialize(caller_id, service_name, service_type, callback, port=0)
      @host = "localhost"
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
      @server = TCPServer.open(port)
      saddr = @server.getsockname
      @port = Socket.unpack_sockaddr_in(saddr)[0]
      @callback = callback
    end

    def send_ok_byte(socket)
      socket.write([1].pack('c'))
    end

    def read_and_callback(socket)
      data_bytes = socket.recv(4).unpack("V")[0]
      request = @service_type::Request.new
      response = @service_type::Response.new
      if data_bytes > 0
        data = socket.recv(data_bytes)
        request.deserialize(data)
      end
      result = @callback.call(request, response)
      if result
        send_ok_byte(socket)
        socket.write(response.serialize)
        socket.flush
      else
        send_header(socket, true)
        socket.flush
        # write some message
      end
    end

    def start
      @accept_thread = Thread.new do
        while socket = @server.accept do
        p 'accept'
        @thread = Thread.new do
          total_bytes = socket.recv(4).unpack("V")[0]
          data = socket.recv(total_bytes)
          header = Header.new
          header.deserialize(data)
          # not documented protocol?
          if header['probe'] == '1'
            send_header(socket)
          elsif check_header(header)
            send_header(socket)
            read_and_callback(socket)
            if header['persistent'] == '1'
              loop do
                read_and_callback(socket)
              end
            end
          else
            socket.close
            raise 'header check error'
          end
        end
        end
      end
    end

    def check_header(header)
      if header['md5sum'] == @service_type.md5sum
        return true
      end
      return false
    end

    def send_header (socket)
      header = Header.new
      header["callerid"] = @caller_id
      header['type'] = @service_type.type_string
      header['md5sum'] = @service_type.md5sum
      socket.write(header.serialize)
      socket.flush
    end
    
    def close
      @server.close
    end
    
    attr_reader :port, :host
    
  end
end
