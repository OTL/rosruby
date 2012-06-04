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
    # write message to socket.
    # @param [IO] socket socket for writing
    # @param [Message] msg message for writing
    # @return [String] wrote data
    def write_msg(socket, msg)
      sio = StringIO.new('', 'r+')
      len = msg.serialize(sio)
      sio.rewind
      data = sio.read
      len = data.length
      data = [len, data].pack("La#{len}")
      socket.write(data)
      data
    end

    ##
    # read the size of data and read it from socket.
    # @param [IO] socket socket for reading
    # @return [String] received data
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
    # @param [String] socket socket for reading
    # @return [Header] header
    def read_header(socket)
      header = ::ROS::TCPROS::Header.new
      header.deserialize(read_all(socket))
      header
    end

    ##
    # write a connection header to socket.
    # @param [IO] socket socket for writing.
    # @param [Header] header header data
    def write_header(socket, header)
      header.serialize(socket)
      socket.flush
    end

    # @return [String] prototol string 'TCPROS'
    def protocol
      'TCPROS'
    end
  end
end
