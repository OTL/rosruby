#!/usr/bin/env ruby

require 'ros'
require 'std_msgs/String'

def main
  node = ROS::Node.new('/rosruby/sample_subscriber')
  node.subscribe('/chatter', Std_msgs::String) do |msg|
    puts "message come! = \'#{msg.data}\'"
  end

  while node.ok?
    node.spin_once
    sleep(1)
  end

end

main
