require 'ros/topic'
require 'ros/tcpros/client'
require 'xmlrpc/client'

module ROS

  class Subscriber < Topic
    
    def initialize(caller_id, topic_name, topic_type, callback=nil, tcp_no_delay=nil)
      super(caller_id, topic_name, topic_type)
      @callback = callback
      @tcp_no_delay = tcp_no_delay
    end
    
    attr_reader :tcp_no_delay, :callback

    def process_queue
      @connections.each_value do |connection|
        while not connection.msg_queue.empty?
          @callback.call(connection.msg_queue.pop)
        end
      end
    end

    def add_connection(uri)
      publisher = XMLRPC::Client.new2(uri)
      code, message, val = publisher.call("requestTopic",
                                          @caller_id, @topic_name, [["TCPROS"]])
      if code == 1
        protocol, host, port = val
        if protocol == "TCPROS"
          new_connection = TCPROS::Client.new(host, port, @caller_id, @topic_name, @topic_type, @tcp_no_delay)
          new_connection.start
        else
          puts "not support protocol: #{protocol}"
          raise "not support protocol: #{protocol}"
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
