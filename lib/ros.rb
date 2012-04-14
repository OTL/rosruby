#  ros/ros.rb 
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

#
# start up file.
# add rospackage paths to $:.
#

require 'ros/package'

this_package = ROS::Package.new(ROS::Package.find_this_package)
this_package.add_path_with_depend_packages

require 'ros/node'
