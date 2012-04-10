#! /usr/bin/ruby 

require 'ros/node'
require 'std_msgs/string'

def main
  node = ROS::Node.new('hoge')
  publisher = node.advertise('/topic_test2', Std_msgs::String)
  sleep(1)
  msg = Std_msgs::String.new
  msg.data = 'hogehoge'
  while node.ok?
    publisher.publish(msg)
    sleep (1.0)
  end
end

main
