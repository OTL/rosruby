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
    def initialize(caller_id, topic_name, topic_type)
      @caller_id = caller_id
      @topic_name = topic_name
      @topic_type = topic_type
      @connections = []
      @connection_id_number = 0
    end

    attr_reader :caller_id, :topic_name, :topic_type

    # shutdown all connections
    def shutdown
      @connections.each {|connection| connection.shutdown}
    end

  end
end
