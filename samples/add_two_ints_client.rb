#!/usr/bin/env ruby

require 'ros'

require 'roscpp_tutorials/TwoInts'

def main
  if ARGV.length < 2
    puts "usage: #{$0} X Y"
    return
  end
  node = ROS::Node.new('/rosruby/sample_service_client')
  if node.wait_for_service('/add_two_ints', 1)
    service = node.service('/add_two_ints', Roscpp_tutorials::TwoInts)
    req = Roscpp_tutorials::TwoInts.request_class.new(:a=>ARGV[0].to_i,
                                                      :b=>ARGV[1].to_i)
    res = Roscpp_tutorials::TwoInts.response_class.new
    if service.call(req, res)
      p res.sum
    end
  end
end

main
