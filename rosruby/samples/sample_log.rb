#!/usr/bin/env ruby 

require 'ros'

def main
  node = ROS::Node.new('/hoge')
  sleep(1)
  node.loginfo('some information')
  node.logdebug('some debug information')
  node.logerr('some error information')
  node.logerror('some error information')
  node.logfatal('some fatal information')
  sleep(1)
end

main
