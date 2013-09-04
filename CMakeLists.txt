cmake_minimum_required(VERSION 2.8.3)
project(rosruby)

find_package(catkin REQUIRED COMPONENTS)

find_package(Ruby)

###################################
## catkin specific configuration ##
###################################
catkin_package(
   CATKIN_DEPENDS roslang rosgraph_msgs
   DEPENDS ruby
)


# all install targets should use catkin DESTINATION variables
# See http://ros.org/doc/api/catkin/html/adv_user_guide/variables.html

## Mark executable scripts (Python etc.) for installation
## in contrast to setup.py, you can choose the destination
install(PROGRAMS
  bin/rubyroscore
  samples/add_two_ints_client.rb
  samples/add_two_ints_server.rb
  samples/gui.rb
  samples/sample_log.rb
  samples/sample_param.rb
  samples/sample_publisher.rb
  samples/sample_subscriber.rb
  scripts/genmsg_ruby.py
  scripts/gensrv_ruby.py
  scripts/rosruby_genmsg.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY lib/
  DESTINATION ${CATKIN_GLOBAL_LIB_DESTINATION}/ruby
  FILES_MATCHING PATTERN "*.rb"
)

## Mark other files for installation (e.g. launch and bag files, etc.)
# install(FILES
#   # myfile1
#   # myfile2
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
# )
