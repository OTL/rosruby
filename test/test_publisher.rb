#! /usr/bin/ruby 

require 'ros/node'
require 'ros/string'

def main
  node = ROS::Node.new('hoge')
  publisher = node.advertise('/topic_test2', ROS::String)
  sleep(1)
  msg = ROS::String.new
  msg.data = 'hogehoge'
  while node.ok?
    publisher.publish(msg)
    sleep (1.0)
  end
end

main
