#  log.rb 
#
# $Revision: $
# $Id:$
# $Date:$
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# = Logger for ROS
#
# creates /rosout publisher and combine Ruby Logger
# 

require 'ros'
require 'rosgraph_msgs/Log'
require 'logger'

module ROS

  # = Logging class for ROS
  # This class enable double logging: ROS Logging system and ruby log.
  # 
  class Log
    
    # topic name of rosout
    ROSOUT_TOPIC='/rosout'

    ##
    # start publishing /rosout and
    # make a ruby logger instance for local output
    #
    def initialize(node)
      @node = node
      @rosout = @node.advertise(ROSOUT_TOPIC, Rosgraph_msgs::Log, nil, nil)
      @ruby_dict = {'FATAL'=>Logger::FATAL,
        'ERROR'=>Logger::ERROR,
        'WARN'=>Logger::WARN,
        'INFO'=>Logger::INFO,
        'DEBUG'=>Logger::DEBUG}
      @msg_dict = {'FATAL'=>::Rosgraph_msgs::Log::FATAL,
        'ERROR'=>::Rosgraph_msgs::Log::ERROR,
        'WARN'=>::Rosgraph_msgs::Log::WARN,
        'INFO'=>::Rosgraph_msgs::Log::INFO,
        'DEBUG'=>::Rosgraph_msgs::Log::DEBUG}
      @local_logger = Logger.new(STDOUT)
    end

    ##
    # outputs log messages with level and informations which
    # rosout needs.
    #
    def log(severity, message, file='', function='', line=0)
      @local_logger.log(@ruby_dict[severity], message, @node.node_name)
      msg = Rosgraph_msgs::Log.new
      msg.msg = message
      msg.header.stamp = ::ROS::Time.now
      msg.level = @msg_dict[severity]
      msg.name = @node.node_name
      msg.file = file
      msg.function = function
      msg.line = line
      msg.topics = @node.get_published_topics
      @rosout.publish(msg)
    end
  end
end
