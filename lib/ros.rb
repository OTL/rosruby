#  ros.rb
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
ROS::load_manifest('rosruby')
require 'ros/node'
