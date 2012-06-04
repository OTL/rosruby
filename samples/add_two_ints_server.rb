#!/usr/bin/env ruby

require 'ros'
require 'roscpp_tutorials/TwoInts'

def main
  node = ROS::Node.new('/rosruby/sample_service_server')
  server = node.advertise_service('/add_two_ints', Roscpp_tutorials::TwoInts) do |req, res|
    res.sum = req.a + req.b
    node.loginfo("a=#{req.a}, b=#{req.b}")
    node.loginfo("  sum = #{res.sum}")
    true
  end

  while node.ok?
    sleep (1.0)
  end
end

main
