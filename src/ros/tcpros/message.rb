#  message.rb
#
# $Revision: $
# $Id:$
# $Date:$
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# super class of TCPROS connections
# document is http://ros.org/wiki/ROS/TCPROS
#
require 'stringio'
require 'ros/tcpros'
require 'ros/tcpros/header'

module ROS::TCPROS
  module Message

    ##
    # @return wrote bytes
    #
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
    # read the size of data and read it.
    #
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
    #
    def read_header(socket)
      header = ::ROS::TCPROS::Header.new
      header.deserialize(read_all(socket))
      header
    end

    ##
    # write a connection header to socket
    #
    def write_header(socket, header)
      header.serialize(socket)
      socket.flush
    end
  end
end
