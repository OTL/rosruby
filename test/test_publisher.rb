#! /usr/bin/ruby 

require 'ros/node'
require 'ros/string'

def main
  node = ROS::Node.new('hoge')
  publisher = node.advertise('/topic_test2', ROS::String)
  sleep(1)
  msg = ROS::String.new
  msg.data = 'hogehoge'
  while true
    publisher.publish(msg)
    sleep (1.0)
  end
  node.shutdown
end

main
