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

if not ENV['ROS_MASTER_URI']
  ENV['ROS_MASTER_URI'] = 'http://localhost:11311'
  puts "Warning: ROS_MASTER_URI is not set. Using #{ENV['ROS_MASTER_URI']}"
end

ENV['RUBYLIB'].split(':').each do |rubylib_path|
  ["#{rubylib_path}/msg", "#{rubylib_path}/srv"].each do |path|
    if File.exists?(path)
      if not $:.include?(path)
        $:.push(path)
      end
    end
  end
end
require 'ros/node'

# ensure shutdown all nodes
END {ROS::Node.shutdown_all_nodes}
