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

  ##
  # == Logger for local output
  # output with color escape sequence
  class LocalLogger

    ##
    # make local logger with color
    #
    # @param [IO] io IO object for output
    def initialize(io)
      @logger = Logger.new(io)
      # add color escape sequence
      @logger.formatter = proc {|severity, datetime, progname, msg|
        header = ''
        footer = ''
        if severity == 'ERROR' or severity == 'FATAL' 
          header = "\e[31m"
          footer = "\e[0m"
        elsif severity == 'WARN'
          header = "\e[33m"
          footer = "\e[0m"
        end
        header + "[#{severity}] #{msg}" + footer + "\n"
      }
    end

    ##
    # output to logger with unixtime
    # @param [String] severity log level
    # @param [String] message message for output
    # @param [String] progname name of this program (node name)
    def log(severity, message, progname)
      return @logger.log(severity, "[Walltime: #{::Time.now.to_f}] " + message, progname)
    end
  end

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
      @local_logger = LocalLogger.new(output)
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
