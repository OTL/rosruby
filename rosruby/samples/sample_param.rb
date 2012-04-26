#!/usr/bin/env ruby

require 'ros'
require 'std_msgs/String'

def main
  node = ROS::Node.new('/rosruby/sample_publisher')
  publisher = node.advertise('/chatter', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new

  while node.ok?
    msg.data = "local param = #{node.get_param('~message')}, global = #{node.get_param('/message')}"
    publisher.publish(msg)
    node.loginfo(msg.data)
    sleep (1.0)
  end
end

main
