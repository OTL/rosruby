module ROS
  class String
    def initialize()
      @data = ''
    end

    attr_accessor :data

    def serialize
      data_length = 4 + @data.length
      [data_length + 4, data_length, @data].pack("VVa*")
    end

    def deserialize(data)
      field_byte, data = data.unpack("Va*")
      @data = data
      return self
    end

    def self.message_definition
      "string data\n\n"
    end

    def self.md5sum
      '992ce8a1687cec8c8bd883ec73ca41d1'
    end

    def self.type_string
      'std_msgs/String'
    end
  end

end
