#! /usr/bin/ruby 

require 'ros/node'
require 'roscpp_tutorials/twoints'

def main
  node = ROS::Node.new('hoge')
  if node.wait_for_service('/add_two_ints', 1)
    service = node.service('/add_two_ints', Roscpp_tutorials::TwoInts)
    req = Roscpp_tutorials::TwoInts.request_class.new
    res = Roscpp_tutorials::TwoInts.response_class.new
    req.a = 10
    req.b = 3
    if service.call(req, res)
      p res.sum 
    end
  end
end

main
