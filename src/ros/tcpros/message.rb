require 'ros/tcpros'

module ROS::TCPROS
  module Message
    def write_msg(msg, socket)
      sio = StringIO.new('', 'r+')
      len = msg.serialize(sio)
      sio.rewind
      data = sio.read
      len = data.length
      socket.write([len, data].pack("Va#{len}"))
    end
  end
end
