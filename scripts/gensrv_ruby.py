#!/usr/bin/env python
# Software License Agreement (BSD License)
#
# Copyright (c) 2012, Takashi Ogura
#
# based on 
#
# Copyright (c) 2008, Willow Garage, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#  * Neither the name of Willow Garage, Inc. nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Revision $Id:$


"""
ROS message source code generation for rospy.

Converts ROS .srv files into Python source code implementations.
"""
import roslib

import roslib.srvs

import genmsg_ruby

REQUEST ='Request'
RESPONSE='Response'

import sys
import os

def srv_generator(package, name, spec):
    req, resp = ["%s%s"%(name, suff) for suff in [REQUEST, RESPONSE]]

    fulltype = '%s%s%s'%(package, roslib.srvs.SEP, name)

    gendeps_dict = roslib.gentools.get_dependencies(spec, package)
    md5 = roslib.gentools.compute_md5(gendeps_dict)
    yield "module %s\n"%package.capitalize()
    yield "class %s\n"%name
    yield """  def self.type
    '%s'
  end
"""%fulltype
    yield """  def self.md5sum
    '%s'
  end
"""%md5
    yield """  def self.request_class
    %s
  end
"""%req
    yield """  def self.response_class
    %s
  end
end
end"""%resp

def gen_srv(path, output_dir_prefix=None):
    f = os.path.abspath(path)
    (package_dir, package) = roslib.packages.get_dir_pkg(f)
    (name, spec) = roslib.srvs.load_from_file(f, package)
    base_name = roslib.names.resource_name_base(name)
    if not output_dir_prefix:
        output_dir_prefix = '%s/srv_gen/ruby'%package_dir
    output_dir = '%s/%s'%(output_dir_prefix, package)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    out = open('%s/%s.rb'%(output_dir, base_name), 'w')
    for mspec, suffix in ((spec.request, REQUEST), (spec.response, RESPONSE)):
        out.write(genmsg_ruby.msg_generator(package, base_name+suffix, mspec))
    for l in srv_generator(package, base_name, spec):
        out.write(l)
    out.close()

if __name__ == "__main__":
    for arg in sys.argv[1:]:
        gen_srv(arg)

