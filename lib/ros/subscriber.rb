# ros/subscriber.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
=begin rdoc

=ROS Subscriber
 subscriber of ROS topic. Please use proc block for callback method.
 See below usage.

=Usage
  node = ROS::Node.new('/rosruby/sample_subscriber')
  node.subscribe('/chatter', Std_msgs::String) do |msg|
    puts "message come! = \'#{msg.data}\'"
  end

  while node.ok?
    node.spin_once
    sleep(1)
  end
=end

require 'ros/topic'
require 'ros/tcpros/client'
require 'xmlrpc/client'

module ROS

  # subscriber of ROS topic. Please use proc block for callback method.
  # this use ROS::TCPROS::Client for message transfer.
  class Subscriber < Topic

    def initialize(caller_id, topic_name, topic_type, callback=nil, tcp_no_delay=nil)
      super(caller_id, topic_name, topic_type)
      @callback = callback
      @tcp_no_delay = tcp_no_delay
    end

    attr_reader :tcp_no_delay, :callback

    ##
    # this is called by node.spin_once.
    # execute callback for all queued messages.
    def process_queue
      @connections.each do |connection|
        while not connection.msg_queue.empty?
          msg = connection.msg_queue.pop
          if @callback
            @callback.call(msg)
          end
        end
      end
    end

    ##
    # request topic to master and start connection with publisher.
    # this creates ROS::TCPROS::Client.
    def add_connection(uri)
      publisher = XMLRPC::Client.new2(uri)
      code, message, val =
        publisher.call("requestTopic",
                       @caller_id, @topic_name, [["TCPROS"]])
      if code == 1
        protocol, host, port = val
        if protocol == "TCPROS"
          connection = TCPROS::Client.new(host, port, @caller_id, @topic_name, @topic_type, uri, @tcp_no_delay)
          connection.start
        else
          puts "not support protocol: #{protocol}"
          raise "not support protocol: #{protocol}"
        end
        connection.id = "#{@topic_name}_in_#{@connection_id_number}"
        @connection_id_number += 1
        @connections.push(connection)
        return connection
      else
        raise "requestTopic fail"
      end
    end

    ##
    # data of connection. for slave API
    #
    def get_connection_data
      @connections.map do |connection|
        [connection.id, connection.byte_received, 1]
      end
    end

    ##
    # connection information fro slave API
    #
    def get_connection_info
      info = []
      @connections.each do |connection|
        info.push([connection.id, connection.target_uri, 'i', 'TCPROS', @topic_name])
      end
      info
    end

  end
end
