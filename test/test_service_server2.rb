#! /usr/bin/ruby 

require 'ros/node'
require 'roscpp_tutorials/two_ints'

def main
  node = ROS::Node.new('hoge')
  server = node.advertise_service('/service2', Roscpp_tutorials::TwoInts,
                                  proc {|req, res| res.sum = req.a + req.b; true})
  while node.ok?
    sleep (1.0)
  end
end

main
