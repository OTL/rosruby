#! /usr/bin/ruby 

require 'ros/node'
require 'roscpp_tutorials/two_ints'

def main
  node = ROS::Node.new('hoge')
  service = node.service('/add_two_ints', Roscpp_tutorials::TwoInts)
  req = Roscpp_tutorials::TwoInts::Request.new
  res = Roscpp_tutorials::TwoInts::Response.new
  req.a = 10
  req.b = 3
  if service.call(req, res)
    p res.sum 
  end
end

main
