#!/usr/bin/env ruby

require 'ros'
require 'test/unit'
require 'roscpp_tutorials/TwoInts'

class TestService < Test::Unit::TestCase
  def test_service
    node = ROS::Node.new('/test_service1')
    server = node.advertise_service('/add_two_ints', Roscpp_tutorials::TwoInts) do |req, res|
      res.sum = req.a + req.b
      node.loginfo("a=#{req.a}, b=#{req.b}")
      node.loginfo("  sum = #{res.sum}")
      if req.a == -1
        false
      else
        true
      end
    end
    assert(node.wait_for_service('/add_two_ints', 1))
    service = node.service('/add_two_ints', Roscpp_tutorials::TwoInts)
    req = Roscpp_tutorials::TwoInts.request_class.new
    res = Roscpp_tutorials::TwoInts.response_class.new
    req.a = 15
    req.b = -50
    assert(service.call(req, res))
    assert_equal(-35, res.sum)
    # fails
    req.a = -1
    assert(!service.call(req, res))
    assert(!node.wait_for_service('/xxxxxxx', 0.1))
    node.shutdown
  end
end
