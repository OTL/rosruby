#! /usr/bin/env python

# msg/srv generator for precompiled system
# It is useful if you are using precompiled ROS system,
# because it needs root access and there are ROS_NOBUILD file in the packages.
# This script generates *.rb files in the rosruby dir.

import genmsg_ruby
import gensrv_ruby
from roslib.packages import get_pkg_dir

# for electirc
try:
    from roslib.packages import ROSPackages
    def get_all_deps(packages):
        rp = ROSPackages()
        depends = rp.depends(packages)
        all_deps = set()
        for packs in depends.values():
            for pack in packs:
                all_deps.add(pack)
        for pack in packages:
            all_deps.add(pack)
        return all_deps
# for fuerte
except ImportError:
    from rospkg import RosPack
    def get_all_deps(packages):
        rp = RosPack()
        all_deps = set()
        for pack in packages:
            depends = rp.get_depends(pack)
            for dep in depends:
                all_deps.add(dep)
        for pack in packages:
            all_deps.add(pack)
        return all_deps
import sys
import os



if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='generate rosruby msg/srv files')
    parser.add_argument('packages', nargs='+')
    parser.add_argument('-d', '--output-dir')
    args = parser.parse_args()
    packages = args.packages
    base_dir = os.environ.get("HOME") + "/.ros/rosruby"
    if args.output_dir:
        base_dir = args.output_dir
    for pack in get_all_deps(packages):
        msg_dir = "%s/msg/"%get_pkg_dir(pack)
        msg_output_prefix = "%s/msg"%base_dir
        if os.path.exists(msg_dir):
            for file in os.listdir(msg_dir):
                base, ext = os.path.splitext(file)
                if ext == '.msg':
                    print "generating " + file
                    genmsg_ruby.gen_msg(msg_dir+file, msg_output_prefix)

        srv_dir = "%s/srv/"%get_pkg_dir(pack)
        srv_output_prefix = "%s/srv"%base_dir
        if os.path.exists(srv_dir):
            for file in os.listdir(srv_dir):
                base, ext = os.path.splitext(file)
                if ext == '.srv':
                    print "generating " + file
                    gensrv_ruby.gen_srv(srv_dir+file, srv_output_prefix)
