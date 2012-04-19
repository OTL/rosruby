# ros/publisher.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
=begin rdoc

=ROS Topic Publisher

This is impl class of publisher. rosruby should hide the interfaces
by impl pattern or so on.

=Usage

  node = ROS::Node.new('/rosruby/sample_publisher')
  publisher = node.advertise('/chatter', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new
  i = 0
  while node.ok?
    msg.data = "Hello, rosruby!: #{i}"
    publisher.publish(msg)

=System

a publisher contains multi connection with subscribers.
TCPROS protocol is in ROS::TCPROS::Server class

=end

require 'ros/topic'
require 'ros/tcpros/server'

module ROS


=begin rdoc

=ROS Topic Publisher

This is impl class of publisher. rosruby should hide the interfaces
by impl pattern or so on.

=Usage

  node = ROS::Node.new('/rosruby/sample_publisher')
  publisher = node.advertise('/chatter', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new
  i = 0
  while node.ok?
    msg.data = "Hello, rosruby!: #{i}"
    publisher.publish(msg)

=System

a publisher contains multi connection with subscribers.
TCPROS protocol is in ROS::TCPROS::Server class

=end
  class Publisher < Topic

    def initialize(caller_id, topic_name, topic_type, is_latched, host)
      super(caller_id, topic_name, topic_type)
      @host = host
      @is_latched = is_latched
      @seq = 0
    end

    ##
    # publish msg object
    #
    def publish(message)
      @seq += 1
      if message.has_header?
        message.header.seq = @seq
      end
      @connections.each do |connection|
        connection.msg_queue.push(message)
      end
    end

    ##
    # add tcpros connection as server
    #
    def add_connection(caller_id)
      connection = TCPROS::Server.new(@caller_id, @topic_name, @topic_type,
                                      @is_latched,
                                      0, @host)
      connection.start
      connection.id = "#{@topic_name}_out_#{@connection_id_number}"
      @connection_id_number += 1
      @connections.push(connection)
      return connection
    end

    # return connection data for slave api
    def get_connection_data
      @connections.map do |connection|
        [connection.id, connection.byte_sent, connection.num_sent, 1]
      end
    end

    # return connection info for slave api
    def get_connection_info
      info = []
      @connections.each do |connection|
        info.push([connection.id, connection.caller_id, 'o', 'TCPROS', @topic_name])
      end
      info
    end
  end
end
