#!/usr/bin/env ruby

require 'ros'
require 'std_msgs/String'

def main
  node = ROS::Node.new('/rosruby/sample_publisher')
  publisher = node.advertise('/chatter', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new
  i = 0
  while node.ok?
    msg.data = "Hello, rosruby!: #{i}"
    publisher.publish(msg)
    sleep(1.0)
    i += 1
  end
end

main
