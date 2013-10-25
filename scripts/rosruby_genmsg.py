#! /usr/bin/env python

# msg/srv generator for precompiled system
# It is useful if you are using precompiled ROS system,
# because it needs root access and there are ROS_NOBUILD file in the packages.
# This script generates *.rb files in the rosruby dir.

import sys
import os

from rospkg import RosPack

import genmsg
import rosmsg
from genrb.generator import msg_generator
from genrb.generator import srv_generator

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


def generate_rb_files(msg_srv, generator, list_msgs, load_msg_by_type, base_dir, overwrite=True):
    search_path = {}
    for p in rospack.list():
        search_path[p] = [os.path.join(rospack.get_path(p), 'msg'),
                          os.path.join(rospack.get_path(p), 'srv')]
    for pack in all_dep_packages:
        output_prefix = base_dir
        output_dir = "%s/%s/"%(output_prefix, pack)
        all_pkg = list_msgs(pack)
        if all_pkg and not os.path.isdir(output_dir):
            os.makedirs(output_dir)
        for pkg_msg in all_pkg:
            spec = load_msg_by_type(context, pkg_msg, search_path)
            output_file = "%s/%s.rb"%(output_prefix, pkg_msg)
            if os.path.isfile(output_file) and not overwrite:
                print "%s already exists skipping it (please use --overwrite to regenerate it)"%output_file
            else:
                with open(output_file, 'w') as f:
                    for l in generator(context, spec, search_path):
                        f.write(l)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='generate rosruby msg/srv files')
    parser.add_argument('packages', nargs='+')
    parser.add_argument('-d', '--output-dir')
#    parser.add_argument('--overwrite', default=False, help='overwrite .rb file if it is already exists. default: False', action='store_true')
    args = parser.parse_args()
    packages = args.packages
    base_dir = os.environ.get("HOME") + "/.ros/rosruby"
    if args.output_dir:
        base_dir = args.output_dir
    rospack = RosPack()

    context = genmsg.MsgContext.create_default()
    all_dep_packages = get_all_deps(packages)

    generate_rb_files('msg', msg_generator, rosmsg.list_msgs, genmsg.load_msg_by_type, base_dir)
    generate_rb_files('srv', srv_generator, rosmsg.list_srvs, genmsg.load_srv_by_type, base_dir)
