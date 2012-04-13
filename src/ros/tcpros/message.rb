require 'stringio'
require 'ros/tcpros'
require 'ros/tcpros/header'

module ROS::TCPROS
  module Message
    #
    # @return wrote bytes
    #
    def write_msg(msg, socket)
      sio = StringIO.new('', 'r+')
      len = msg.serialize(sio)
      sio.rewind
      data = sio.read
      len = data.length
      data = [len, data].pack("Va#{len}")
      socket.write(data)
      data
    end

    def read_all(socket)
      total_bytes = socket.recv(4).unpack("V")[0]
      if total_bytes and total_bytes > 0
        socket.recv(total_bytes)
      else
        ''
      end
    end

    def read_header(socket)
      header = ::ROS::TCPROS::Header.new
      header.deserialize(read_all(socket))
      header
    end

    def write_header(socket, header)
      header.serialize(socket)
      socket.flush
    end
  end
end
