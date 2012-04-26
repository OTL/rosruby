# ros/topic.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# Super class of Publisher/Subscriber
#
module ROS

  ##
  # Base class of {Publisher} and {Subscriber}
  class Topic

    # initialize member variables
    # @param [String] caller_id caller id of this node
    # @param [String] topic_name name of this topic
    # @param [Class] topic_type class of msg
    def initialize(caller_id, topic_name, topic_type)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @connections = []
      @connection_id_number = 0
    end

    # @return [String] caller id
    attr_reader :caller_id

    # @return [String] name of this topic
    attr_reader :topic_name

    # @return [Class] class of msg
    attr_reader :topic_type

    # shutdown all connections
    def close #:nodoc:
      @connections.each {|connection| connection.shutdown}
    end

    # set manager for shutdown
    # @param [GraphManager] manager
    def set_manager(manager) #:nodoc:
      @manager = manager
    end
  end
end
