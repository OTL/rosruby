# ros/tcpros/message.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# super class of TCPROS connections
# document is http://ros.org/wiki/ROS/TCPROS
#
require 'stringio'
require 'ros/tcpros/header'


# TCP connection between nodes.
# protocol document is http://ros.org/wiki/ROS/TCPROS
module ROS::TCPROS

  # functions for TCPROS
  module Message

    ##
    # write message to socket
    # [+socket+] socket for writing
    # [+msg+] msg class instance
    # [+return+] wrote bytes
    def write_msg(socket, msg)
      sio = StringIO.new('', 'r+')
      len = msg.serialize(sio)
      sio.rewind
      data = sio.read
      len = data.length
      data = [len, data].pack("Va#{len}")
      socket.write(data)
      data
    end

    ##
    # read the size of data and read it from socket
    # [+socket+] socket for reading
    # [+return+] received data (String)
    def read_all(socket)
      total_bytes = socket.recv(4).unpack("V")[0]
      if total_bytes and total_bytes > 0
        socket.recv(total_bytes)
      else
        ''
      end
    end

    ##
    # read a connection header from socket
    # [+socket+] socket for reading
    # [+return+] header (ROS::TCPROS::Header)
    def read_header(socket)
      header = ::ROS::TCPROS::Header.new
      header.deserialize(read_all(socket))
      header
    end

    ##
    # write a connection header to socket
    # [+socket+] socket for reading
    # [+header+] header (ROS::TCPROS::Header)
    def write_header(socket, header)
      header.serialize(socket)
      socket.flush
    end

    # return prototol string 'TCPROS'
    def protocol
      'TCPROS'
    end
  end
end
