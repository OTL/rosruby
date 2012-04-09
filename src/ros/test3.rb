require 'ros/node'
require 'ros/string'

def main
  node = ROS::Node.new('hoge')
  subscriber = node.subscribe('/topic_test3',
                              ROS::String,
                              Proc.new do |data|
                                p data
                              end)
  while true
    node.spin_once
    sleep(1)
  end

  node.shutdown
end

main
