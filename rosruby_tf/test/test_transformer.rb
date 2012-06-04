#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_tf")

require 'test/unit'
require 'tf/transformer'


class TestTransformer < Test::Unit::TestCase
  def setup
    # root --- frame1 ---- frame2
    #       |           |
    #       |           -- frame3
    #       -- framea ---- frameb
    @root = Tf::Transform.new('/root', [0, 0, 0], [0, 0, 0, 1], nil)
    @frame1 = Tf::Transform.new('/frame1', [1, 0, 0], [0, 0, 0, 1], @root)
    @frame2 = Tf::Transform.new('/frame2', [1, 0, 0], [0, 0, 0, 1], @frame1)
    @frame3 = Tf::Transform.new('/frame3', [0, -1, 0], [0, 0, 0, 1], @frame1)
    @framea = Tf::Transform.new('/framea', [-1, 0, 0], [0, 0, 0, 1], @root)
    @frameb = Tf::Transform.new('/frameb', [1, 1, 0], [0, 0, 0, 1], @framea)
  end

  def test_root
    assert_equal([@frame3, @frame1, @root], @frame3.find_root)
    assert_equal([@frame2, @frame1, @root], @frame2.find_root)
    assert_equal([@frame1, @root], @frame1.find_root)
    assert_equal([@root], @root.find_root)
  end

  def test_path
    assert_equal([@framea, @root, @frame1, @frame3], @framea.get_path(@frame3))
    path = @frame2.get_path(@frame3)
    assert_equal([@frame2, @frame1, @frame3], @frame2.get_path(@frame3))
  end

  def test_transform_chain
    puts @framea.get_transform_to(@frame3)
    puts @frame3.get_transform_to(@framea)
    puts @root.get_transform_to(@frame3)
  end
end
