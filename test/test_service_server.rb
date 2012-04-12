#! /usr/bin/ruby 

require 'ros/ros'
require 'roscpp_tutorials/TwoInts'

def main
  node = ROS::Node.new('hoge')
  server = node.advertise_service('/add_two_ints', Roscpp_tutorials::TwoInts,
                                  proc {|req, res| res.sum = req.a + req.b; true})
  while node.ok?
    sleep (1.0)
  end
end

main
