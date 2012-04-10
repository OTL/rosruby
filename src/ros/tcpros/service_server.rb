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
    
    def read_and_callback(socket)
      p 'CALLBACK'
#      data_bytes = socket.recv(4).unpack("V")[0]
#      data = socket.recv(data_bytes)
      p 'DATANUM'
      request = @service_type::Request.new
      response = @service_type::Response.new
#      request.deserialize(data)
      if @callback.call(request, response)
        p 'writing header'
        send_header(socket, true)
        p 'writing data'
        socket.write(response.serialize)
        p 'writing data finish'
        socket.flush
      else
        p 'writing header'
        send_header(socket, true)
        socket.flush
        p 'writing data finish'
        # write some message
      end
    end

    def start
      @accept_thread = Thread.new do
        while socket = @server.accept do
        p 'accept'
        @thread = Thread.new do
#          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
          total_bytes = socket.recv(4).unpack("V")[0]
          data = socket.recv(total_bytes)
          p 'read'
          header = Header.new
          header.deserialize(data)
          p 'deserialize'
          # not documented protocol?
          if header['probe'] == '1'
            send_probe_header(socket)
          elsif check_header(header)
            p 'check OK'
            read_and_callback(socket)
            if header['persistent'] == '1'
              loop do
                read_and_callback(socket)
              end
            end
          else
            p 'header check error'
            socket.close
            raise 'header check error'
          end
        end
        end
      end
    end

    def check_header(header)
      p header
      if header['md5sum'] == @service_type.md5sum
        return true
      end
      return false
    end

    def send_probe_header(socket)
      p 'send_probe_header'
      header = Header.new
      header["callerid"] = @caller_id
      header['type'] = @service_type.type_string
      header['md5sum'] = @service_type.md5sum
      socket.write(header.serialize)
      socket.flush
    end

    def send_header (socket, is_ok)
      header = Header.new
      header["callerid"] = @caller_id
      header['type'] = @service_type.type_string
      header['md5sum'] = @service_type.md5sum
      if is_ok
        header['ok'] = '1'
      else
        header['ok'] = '0'
      end
      socket.write(header.serialize)
      socket.flush
    end
    
    def close
      @server.close
    end
    
    attr_reader :port, :host
    
  end
end
