# ros/log.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# == Logger for ROS
#
# creates /rosout publisher and combine Ruby Logger
#

require 'ros'
require 'rosgraph_msgs/Log'
require 'logger'

module ROS

  # == Logging class for ROS
  # This class enable double logging: ROS Logging system and ruby log.
  class Log

    # topic name of rosout
    ROSOUT_TOPIC='/rosout'

    ##
    # start publishing /rosout and
    # make a ruby logger instance for local output
    # @param [Node] node {Node} instance
    # @param [IO] output local output. $stdout is default
    def initialize(node, output=$stdout)
      @node = node
      @rosout = @node.advertise(ROSOUT_TOPIC, Rosgraph_msgs::Log,
                                :no_resolve=>true)
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
      @local_logger = Logger.new(output)
    end

    ##
    # outputs log messages with level and informations which
    # rosout needs.
    # @param [String] severity  log level: one of 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'
    # @param [String] message  your message
    # @param [String] file file name in which called this method
    # @param [String] function function name in which called this method
    # @param [Integer] line line number in which called this method
    # @return [Log] self
    def log(severity, message, file='', function='', line=0)
      @local_logger.log(@ruby_dict[severity], message, @node.node_name)
      msg = Rosgraph_msgs::Log.new
      msg.msg = message
      msg.header.stamp = ::ROS::Time.now
      msg.header.frame_id = 'rosout'
      msg.level = @msg_dict[severity]
      msg.name = @node.node_name
      msg.file = file
      if /in `(.*)'/ =~ function
        msg.function = $1
      else
        msg.function = ''
      end
      msg.line = line
      msg.topics = @node.get_published_topics
      @rosout.publish(msg)
      self
    end
  end
end
