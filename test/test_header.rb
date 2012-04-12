#!/usr/bin/ruby

require 'test/unit'
require 'ros/tcpros/header'

class TestParam_Normal < Test::Unit::TestCase
  def test_serialize
    header = ROS::TCPROS::Header.new
    header['aa'] = '5'
    assert_equal('5', header['aa'])
    sio = StringIO.new
    header.serialize(sio)
    sio.rewind
    data = sio.read
    assert_equal("\b\000\000\000\004\000\000\000aa=5", data)

    header2 = ROS::TCPROS::Header.new
    assert_equal(header2, header2.deserialize("\b\000\000\000\004\000\000\000aa=5"[4..-1]))
    assert_equal('5', header2['aa'])
  end
end

