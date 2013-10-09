cmake_minimum_required(VERSION 2.8.3)
project(rosruby)

find_package(catkin REQUIRED COMPONENTS
  genrb rosgraph_msgs std_msgs)

include(${PROJECT_SOURCE_DIR}/cmake/rosruby-macro.cmake)

set(ROSRUBY_GENMSG_DIR ${PROJECT_SOURCE_DIR}/scripts)

catkin_package(
  CFG_EXTRAS rosruby-extras.cmake rosruby-macro.cmake
  CATKIN_DEPENDS roslang genrb rosgraph_msgs std_msgs
  DEPENDS ruby
  )

catkin_python_setup()

rosruby_setup()

catkin_add_env_hooks(${PROJECT_NAME} SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)

file(MAKE_DIRECTORY ${ROSRUBY_DEVEL_LIB_DESTINATION})

rosruby_generate_messages(std_msgs rosgraph_msgs)

install(PROGRAMS
  bin/rubyroscore
  scripts/rosruby_genmsg.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

rosruby_add_libraries(
  lib/ros.rb
  lib/ros)

install(DIRECTORY lib/
  DESTINATION ${ROSRUBY_LIB_DESTINATION}
  )

install(FILES
  cmake/rosruby-extras.cmake.em
  cmake/rosruby-macro.cmake
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/cmake)

