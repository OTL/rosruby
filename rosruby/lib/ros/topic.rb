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
  # Base class of ROS::Publisher and ROS::Subscriber
  class Topic

    # initialize member variables
    # [+caller_id+] caller id of this node
    # [+topic_name+] name of this topic (String)
    # [+topic_type+] class of msg
    def initialize(caller_id, topic_name, topic_type)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @connections = []
      @connection_id_number = 0
    end

    # caller id
    attr_reader :caller_id

    # name of this topic (String)
    attr_reader :topic_name

    # class of msg
    attr_reader :topic_type

    # shutdown all connections
    def close #:nodoc:
      @connections.each {|connection| connection.shutdown}
    end

    # set manager for shutdown
    # [+manager+] GraphManager
    def set_manager(manager) #:nodoc:
      @manager = manager
    end
  end
end
