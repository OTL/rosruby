require 'ros/topic'
require 'ros/tcpros/client'
require 'xmlrpc/client'

module ROS

  class Subscriber < Topic
    
    def initialize(caller_id, topic_name, topic_type, callback=nil)
      super(caller_id, topic_name, topic_type)
      @callback = callback
    end
    
    def process_queue
      @connections.each_value do |connection|
        while not connection.msg_queue.empty?
          @callback.call(connection.msg_queue.pop)
        end
      end
    end

    def add_connection(uri)
      publisher = XMLRPC::Client.new2(uri)
      result = publisher.call("requestTopic",
                              caller_id,
                              topic_name,
                              [["TCPROS"]])
      if result[0] == 1
        protocol, host, port = result[2]
        if protocol == "TCPROS"
          new_connection = TCPROS::Client.new(host, port, caller_id, topic_name, topic_type)
          new_connection.send_header
          new_connection.read_header
          new_connection.read_start
        else
          raise "not support protocol" + protocol
        end
        @connections[uri] = new_connection
        new_connection.id = "#{@topic_name}_in_#{@connection_id_number}"
        return new_connection
      else
        raise "requestTopic fail"
      end
    end

    def get_connection_data
      @connections.values.map do |connection|
        [connection.id, connection.byte_received, 1]
      end
    end

    def get_connection_info
      info = []
      @connections.each do |uri, connection|
        info.push([connection.id, uri, 'i', 'TCPROS', @topic_name])
      end
      info
    end

  end
end
