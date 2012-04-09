require 'test/unit'
require 'ros/node'
require 'ros/string'

class TestParam_Normal < Test::Unit::TestCase
  def test_set_get
    node = ROS::Node('hoge')
    # integer
    assert(node.set_param('/test1', 1))
    assert_equal(1, node.get_param('/test1'))
    # float
    assert(node.set_param('/test_f', 0.1))
    assert_equal(0.1, node.get_param('/test_f'))
    # list
    assert(node.set_param('/test2', [1,2,3]))
    assert_equal([1,2,3], node.get_param('/test2'))
    # string
    assert(node.set_param('/test_s', 'hoge'))
    assert_equal('hoge', node.get_param('/test_s'))

    node.shutdown
  end

  def test_fail
    node = ROS::Node.new('hoge')
    assert(!node.get_param('/test_no_exists'))
    node.shutdown
  end

  def test_resolve_name
    node = ROS::Node.new('hoge')
    
    assert_equal('/aaa', node.resolve_name('aaa'))
    assert_equal('/aaa/b/c', node.resolve_name('aaa/b////c'))
    assert_equal('/hoge/private', node.resolve_name('~private'))
    node.shutdown
  end
end


class TestPub_Normal < Test::Unit::TestCase
  def test_advertise
    node = ROS::Node.new('hoge')
    publisher = node.advertise('/topic_test', 'std_msgs/String')
    sleep(0.5)
    msg = ROS::String.new
    msg.data = 'hogehoge'
    publisher.publish(msg)
    while true
    end
  end
end
