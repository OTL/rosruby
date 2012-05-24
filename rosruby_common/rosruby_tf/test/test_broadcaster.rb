#!/usr/bin/env ruby

require 'ros'
ROS::load_manifest("rosruby_tf")
require 'test/unit'
require 'tf/broadcaster'

class TestTfBroadcaster < Test::Unit::TestCase
  def test_broadcast
    node = ROS::Node.new('/tf_test')
    tf_broadcaster = Tf::TransformBroadcaster.new(node)

    @msg = nil
    node.subscribe('/tf', Tf::TfMessage) do |msg|
      @msg = msg
    end
    sleep 1

    now = ROS::Time::now
    tf_broadcaster.send_transform([1.0, 2.0, 3.0], [0.0,0.0,0.0,1.0], now, '/child', '/parent')
    sleep 1
    node.spin_once

    assert(@msg)
    tf = @msg.transforms[0]
    assert_equal(now, tf.header.stamp)
    assert_equal('/parent', tf.header.frame_id)
    assert_equal('/child', tf.child_frame_id)
    assert_equal(1.0, tf.transform.translation.x)
    assert_equal(2.0, tf.transform.translation.y)
    assert_equal(3.0, tf.transform.translation.z)

    assert_equal(0.0, tf.transform.rotation.x)
    assert_equal(0.0, tf.transform.rotation.y)
    assert_equal(0.0, tf.transform.rotation.z)
    assert_equal(1.0, tf.transform.rotation.w)

  end
end
