require 'ros/tcpros'

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
  end
end
