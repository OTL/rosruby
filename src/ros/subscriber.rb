#require 'ros/serializer'
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

    def drop_connection(uri)
      @connections[uri].close
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
          p new_connection.read_header
          new_connection.read_start
        else
          raise "not support protocol" + protocol
        end
        @connections[uri] = new_connection
        return new_connection
      else
        raise "requestTopic fail"
      end
    end

    def has_connection_with?(uri)
      return @connections[uri]
    end

    def get_connected_uri
      return @connections.keys
    end
  end
end
