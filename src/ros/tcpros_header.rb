module ROS
  module TCPROS
    class Header
      def initialize
        @data = {}
      end
      
      def push_data(key, value)
        @data[key] = value
      end

      def deserialize(data)
      end

      def serialize
        serialized_data = ''
        @data.each_pair do |key, value|
          data_str = key + '=' + value
          serialized_data = serialized_data + [data_str.length, data_str].pack('Va*')
        end
        total_byte = serialized_data.length
        return serialized_data = [total_byte, serialized_data].pack('Va*')
      end

    end
  end
end
        
