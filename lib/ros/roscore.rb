#!/usr/bin/env ruby

require 'ros/master'
require 'ros'
require 'timeout'

module ROS

  ##
  # Wait until roscore is ready.
  # @param [Float] timeout_sec time to wait [sec]
  # @return [Bool] true: roscore is ready now. false: timeout.
  def self.wait_roscore(timeout_sec=10.0)
    proxy = XMLRPC::Client.new2(ENV['ROS_MASTER_URI']).proxy
    pid = nil
    begin
      timeout(timeout_sec) do
        while not pid
          begin
            pid = proxy.getPid('/roscore')
          rescue
            sleep 0.5
          end
        end
      end
      true
    rescue Timeout::Error
      false
    end
  end

  ##
  # Start roscore.
  # starts rosmaster and rosout.
  def self.start_roscore
    # master
    thread = Thread.new do
      ROS::Master.new.start
    end

    if not wait_roscore(10.0)
      raise "rosmaster did not response in 10.0 secs"
    end

    # rosout
    rosout_node = ROS::Node.new('/rosout', :nologger=>true)
    rosout_agg_publisher = rosout_node.advertise('/rosout_agg', Rosgraph_msgs::Log)
    rosout_node.subscribe('/rosout', Rosgraph_msgs::Log) do |msg|
      rosout_agg_publisher.publish(msg)
    end
    rosout_node.spin
  end
end

if $0 == __FILE__
  ROS::start_roscore
end
