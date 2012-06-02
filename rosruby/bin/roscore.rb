#!/usr/bin/env ruby

require 'ros/master'
require 'ros'

# master
thread = Thread.new do 
  ROS::Master.new.start
end

sleep 1

# rosout
rosout_node = ROS::Node.new('/rosout')
rosout_agg_publisher = rosout_node.advertise('/rosout_agg', Rosgraph_msgs::Log)
rosout_node.subscribe('/rosout', Rosgraph_msgs::Log) do |msg|
  rosout_agg_publisher.publish(msg)
end

rosout_node.spin
