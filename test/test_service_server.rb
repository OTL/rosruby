#! /usr/bin/ruby 

require 'ros/node'
require 'std_srvs/empty'

def main
  node = ROS::Node.new('hoge')
  server = node.advertise_service('/service', Std_srvs::Empty,
                                  proc {p 'service come!';
                                  return true})

  while node.ok?
    sleep (1.0)
  end
end

main
