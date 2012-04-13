require 'ros/topic'
require 'ros/tcpros/server'

module ROS

  class Publisher < Topic

    def initialize(caller_id, topic_name, topic_type, is_latched, host)
      super(caller_id, topic_name, topic_type)
      @host = host
      @is_latched = is_latched
      @seq = 0
    end

    def publish(message) 
      @seq += 1
      if message.has_header?
        message.header.seq = @seq
      end
      @connections.each_value do |connection|
        connection.msg_queue.push(message)
      end
    end

    def add_connection(caller_id)
      connection = TCPROS::Server.new(@caller_id, @topic_name, @topic_type, @is_latched,
                                      0, @host)
      connection.start
      connection.id = "#{@topic_name}_out_#{@connection_id_number}"
      @connections[caller_id] = connection
      return connection
    end

    def get_connection_data
      @connections.values.map do |connection|
        [connection.id, connection.byte_sent, connection.num_sent, 1]
      end
    end

    def get_connection_info
      info = []
      @connections.each do |uri, connection|
        info.push([connection.id, uri, 'o', 'TCPROS', @topic_name])
      end
      info
    end
  end
end
