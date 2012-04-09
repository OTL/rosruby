require 'ros/node'
require 'ros/string'

def main
  node = ROS::Node.new('hoge')
  publisher = node.advertise('/topic_test2', ROS::String)
  sleep(0.5)
  msg = ROS::String.new
  msg.data = 'hogehoge'
  publisher.publish(msg)
  sleep (1.0)
  node.shutdown
end

main
