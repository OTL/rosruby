require 'ros/package'

module ROS
end

this_package = ROS::Package.new(ROS::Package.find_this_package)
this_package.add_depend_package_path

require 'ros/node'
