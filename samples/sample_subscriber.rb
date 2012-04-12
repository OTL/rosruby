#! /usr/bin/ruby

require 'ros/ros'
require 'std_msgs/String'

def main
  node = ROS::Node.new('/rosruby/sample_subscriber')
  subscriber = node.subscribe('/chatter',
                              Std_msgs::String,
                              Proc.new do |msg|
                                puts "message come! = \'#{msg.data}\'"
                              end)
  while node.ok?
    node.spin_once
    sleep(1)
  end

end

main
