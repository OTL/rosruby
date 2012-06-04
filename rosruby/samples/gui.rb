#! /usr/bin/env ruby

#
# = sample of gui (Ruby/Tk)
# this sample needs geometry_msgs/Twist.
# The GUI publishes velocity as Twist.
#
# if you don't have the message files, try
#
# $ rosrun rosruby rosruby_genmsg.py geometry_msgs
#

require 'tk'
require 'ros'
require 'geometry_msgs/Twist'

topic_name = '/cmd_vel'
node = ROS::Node.new('/gui_test')
pub = node.advertise(topic_name, Geometry_msgs::Twist)

linear_vel = 0.5
angular_vel = 1.0

TkButton.new {
  text "FORWARD"
  command do
    msg = Geometry_msgs::Twist.new
    msg.linear.x = linear_vel
    pub.publish(msg)
  end
  width 10
  grid("row"=>0, "column"=>1)
}

TkButton.new {
  text "LEFT"
  command do
    msg = Geometry_msgs::Twist.new
    msg.angular.z = angular_vel
    pub.publish(msg)
  end
  width 10
  grid("row"=>1, "column"=>0)
}

TkButton.new {
  text "STOP"
  command do
    msg = Geometry_msgs::Twist.new
    pub.publish(msg)
  end
  width 10
  grid("row"=>1, "column"=>1)
}

TkButton.new {
  text "RIGHT"
  command do
    msg = Geometry_msgs::Twist.new
    msg.angular.z = -angular_vel
    pub.publish(msg)
  end
  width 10
  grid("row"=>1, "column"=>2)
}


TkButton.new {
  text "BACKWARD"
  command do
    msg = Geometry_msgs::Twist.new
    msg.linear.x = -linear_vel
    pub.publish(msg)
  end
  width 10
  grid("row"=>2, "column"=>1)
}

TkScale.new {
  label 'linear vel(%)'
  from 0
  to 100
  orient 'horizontal'
  command do |val|
    linear_vel = val.to_f * 0.005
  end
  grid("row"=>3, "column"=>0)
}.set(50)

TkScale.new {
  label 'angular vel(%)'
  from 0
  to 100
  orient 'horizontal'
  command do |val|
    angular_vel = val.to_f * 0.01
  end
  grid("row"=>3, "column"=>1)
}.set(50)

TkButton.new {
  text "exit"
  command do
    node.shutdown
    exit
  end
  width 5
  grid("row"=>3, "column"=>2)
}

TkLabel.new {
  text 'topic'
  grid("row"=>4, "column"=>0)
}

TkEntry.new {
  self.value = topic_name
  bind 'Return', proc {
    topic_name = self.value
    pub.shutdown
    pub = node.advertise(topic_name, Geometry_msgs::Twist)
  }
  grid("row"=>4, "column"=>1, "columnspan"=>2, "sticky"=>"news")
}

Tk.mainloop
