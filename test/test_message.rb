#!/usr/bin/env ruby

require 'ros/message'
require 'test/unit'

class TestMessage < Test::Unit::TestCase
  def test_message
    s = ROS::Struct.new('V')
    packed = s.pack(4)
    assert_equal("\004\000\000\000", packed)
    assert_equal(4, s.unpack(packed)[0])
  end
end
