#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest('rosruby_tutorials')

require 'roscpp_tutorials/TwoInts'

if ARGV.length < 2
  puts "usage: #{$0} X Y"
  return
end

node = ROS::Node.new('/rosruby/sample_service_client')

if node.wait_for_service('/add_two_ints', 1)
  service = node.service('/add_two_ints', Roscpp_tutorials::TwoInts)
  req = Roscpp_tutorials::TwoInts.request_class.new
  res = Roscpp_tutorials::TwoInts.response_class.new
  req.a = ARGV[0].to_i
  req.b = ARGV[1].to_i
  if service.call(req, res)
    p res.sum
  end
end
