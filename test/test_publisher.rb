#! /usr/bin/ruby 

require 'ros/ros'
require 'std_msgs/String'

def main
  node = ROS::Node.new('/rosruby/sample_publisher')
  publisher = node.advertise('/chatter', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new
  msg.data = 'Hello, rosruby!'
  while node.ok?
    publisher.publish(msg)
    sleep (1.0)
  end
end

main
