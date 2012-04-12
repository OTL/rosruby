require 'ros/ros'
require 'rosgraph_msgs/Log'
require 'logger'

module ROS

  class Log

    ROSOUT_TOPIC='/rosout'

    def initialize(node)
      @node = node
      @rosout = @node.advertise(ROSOUT_TOPIC, Rosgraph_msgs::Log, nil)
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
