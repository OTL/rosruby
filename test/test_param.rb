#!/usr/bin/env ruby

require 'test/unit'
require 'ros'

class TestParam_Normal < Test::Unit::TestCase
  def test_param_manager
    remap = {'aa'=>1, 'bb'=>'xx'}
    param = ROS::ParameterManager.new(ENV['ROS_MASTER_URI'], '/test_param', remap)
    assert_equal(1, param.get_param('aa'))
    assert(!param.get_param('cc'))

    assert(param.set_param('cc', [1,2]))
    assert_equal([1,2], param.get_param('cc'))
    assert(param.delete_param('cc'))
    assert(!param.get_param('cc'))

    assert(param.set_param('aa', -1))
    assert_equal('/aa', param.search_param('aa'))
    assert_raise(RuntimeError) {param.search_param('xx')}
    assert(!param.has_param('a'))
    assert(param.has_param('aa'))
    assert(param.get_param_names)

    assert(param.delete_param('aa'))
  end
end
