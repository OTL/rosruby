require 'socket'

module ROS
  class TCPROS

    def initialize
      @@next_port = 12345
      @port = generate_port
      @host = "localhost"
      @server = TCPServer.open(@port)
      @socket = @server.accept
    end
    
    def write(data)
      @socket.write(data)
    end

    def close
      @server.close
      @socket.close
    end

    attr_read :port, :host
    
    def generate_port
      @@next_port = @@next_port +1
    end

  end
end
