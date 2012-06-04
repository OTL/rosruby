#!/usr/bin/env ruby

require 'test/unit'
require 'stringio'
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

    header3 = ROS::TCPROS::Header.new
    header3['hoge'] = '1'

    # wild_card
    assert(header3.valid?('hoge', '*'))
  end

  def test_check_string
    header = ROS::TCPROS::Header.new
    assert_raise(ArgumentError) { header['aa'] = 1}
    assert_raise(ArgumentError) { header[5] = '1'}
    assert_raise(ArgumentError) { header[:symbol] = '1'}
    assert_raise(ArgumentError) { header[String] = '1'}
  end
end
