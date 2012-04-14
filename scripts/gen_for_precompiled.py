#! /usr/bin/env python

# msg/srv generator for precompiled system
# It is useful if you are using precompiled ROS system, 
# because it needs root access and there are ROS_NOBUILD file in the packages.
# This script generates *.rb files in the rosruby dir.

import genmsg_ruby
import gensrv_ruby
from roslib.packages import get_pkg_dir

import sys
import os


if __name__ == "__main__":
    if len(sys.argv) == 1:
        packages = ['std_msgs', 'rosgraph_msgs', 'roscpp_tutorials']
    else:
        packages = sys.argv[1:]
    output_prefix = "%s/lib"%get_pkg_dir('rosruby')
    for pack in packages:
        msg_dir = "%s/msg/"%get_pkg_dir(pack)
        if os.path.exists(msg_dir):
            for file in os.listdir(msg_dir):
                genmsg_ruby.gen_msg(msg_dir+file, output_prefix)
        srv_dir = "%s/srv/"%get_pkg_dir(pack)
        if os.path.exists(srv_dir):
            for file in os.listdir(srv_dir):
                gensrv_ruby.gen_srv(srv_dir+file, output_prefix)
