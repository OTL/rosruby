# ros/publisher.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'ros/topic'
require 'ros/tcpros/server'

module ROS
# Publisher interface of ROS.
# A publisher contains multi connection with subscribers.
# TCPROS protocol implementation is in ROS::TCPROS::Server.
# Here is sample code. You can shutdown publisher by using this
# instance (ROS::Publisher#shutdown)
#   node = ROS::Node.new('/rosruby/sample_publisher')
#   publisher = node.advertise('/chatter', Std_msgs::String)
#   sleep(1)
#   msg = Std_msgs::String.new
#   i = 0
#   while node.ok?
#     msg.data = "Hello, rosruby!: #{i}"
#     publisher.publish(msg)
#     i += 1
#   end
  class Publisher < Topic

    # @param [String] caller_id caller_id of this node
    # @param [String] topic_name name of topic to publish (String)
    # @param [Class] topic_type class of topic
    # @param [Boolean] is_latched latched topic?
    # @param [String] host host name of this node
    def initialize(caller_id, topic_name, topic_type, is_latched, host)
      super(caller_id, topic_name, topic_type)
      @host = host
      @is_latched = is_latched
      @seq = 0
    end

    ##
    # publish msg object
    # @param [Class] message instance of topic_type class
    # @return [Publisher] self
    def publish(message)
      @seq += 1
      @last_published_msg = message
      if message.has_header?
        message.header.seq = @seq
      end
      @connections.each do |connection|
        connection.msg_queue.push(message)
      end
      self
    end

    ##
    # add tcpros connection as server
    # @param [String] caller_id caller_id of subscriber
    # @return [TCPROS::Server] connection object
    def add_connection(caller_id) #:nodoc:
      connection = TCPROS::Server.new(@caller_id, @topic_name, @topic_type,
                                      :host=>@host,
                                      :latched=>@is_latched,
                                      :last_published_msg=>@last_published_msg)
      connection.start
      connection.id = "#{@topic_name}_out_#{@connection_id_number}"
      @connection_id_number += 1
      @connections.push(connection)
      return connection
    end

    # get number of subscribers to this publisher
    # @return [Integer] number of subscribers
    def get_number_of_subscribers
      @connections.length
    end

    # @return [Array] connection data for slave api
    def get_connection_data
      @connections.map do |connection|
        [connection.id, connection.byte_sent, connection.num_sent, 1]
      end
    end

    # @return [array] connection info for slave api
    def get_connection_info
      info = []
      @connections.each do |connection|
        info.push([connection.id, connection.caller_id, 'o', connection.protocol, @topic_name])
      end
      info
    end

    ##
    # user interface of shutdown this publisher
    # @return [nil] nil
    def shutdown
      @manager.shutdown_publisher(self)
    end
  end
end
