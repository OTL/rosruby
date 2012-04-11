require 'ros/tcpros'

module ROS::TCPROS
  class Header
    def initialize
      @data = {}
    end

    # key and value must be string
    def push_data(key, value)
      @data[key] = value
    end
    
    def get_data(key)
      @data[key]
    end
    
    alias_method :[]=, :push_data
    alias_method :[], :get_data
    
    # not contain total byte
    def deserialize(data)
      while data.length > 0
        len, data = data.unpack('Va*')
        msg = data[0..(len-1)]
        equal_position = msg.index('=')
        key = msg[0..(equal_position-1)]
        value = msg[(equal_position+1)..-1]
        @data[key] = value
        data = data[(len)..-1]
      end
      self
    end
    
    # contains total byte
    def serialize(buff)
      serialized_data = ''
      @data.each_pair do |key, value|
        data_str = key + '=' + value
        serialized_data = serialized_data + [data_str.length, data_str].pack('Va*')
      end
      total_byte = serialized_data.length
      return buff.write([total_byte, serialized_data].pack('Va*'))
    end
    
  end
end
        
