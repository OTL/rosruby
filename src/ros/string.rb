module ROS
  class String
    def initialize()
      @data = ''
    end

    attr_accessor :data

    def get_serialized_data
      data
    end

    def get_message_definition_str
      "message_definition=string data\n\n"
    end

    def get_md5sum_str
      'md5sum=992ce8a1687cec8c8bd883ec73ca41d1'
    end
    def get_type_str
      'type=std_msgs/String'
    end
  end

end
