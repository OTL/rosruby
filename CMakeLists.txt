cmake_minimum_required(VERSION 2.8.3)
project(rosruby)

find_package(catkin REQUIRED COMPONENTS
  genrb rosgraph_msgs std_msgs)

set(ROSRUBY_GENMSG_DIR ${PROJECT_SOURCE_DIR}/scripts)

catkin_package(
  CFG_EXTRAS rosruby-extras.cmake
  CATKIN_DEPENDS roslang genrb rosgraph_msgs std_msgs
  DEPENDS ruby
  )


#
# macro definitions
#
macro(rosruby_setup)
  set(ROSRUBY_DEVEL_LIB_DESTINATION ${CATKIN_DEVEL_PREFIX}/lib/ruby/vendor_ruby)
  set(ROSRUBY_LIB_DESTINATION ${CATKIN_GLOBAL_LIB_DESTINATION}/ruby/vendor_ruby)
endmacro()


macro(rosruby_add_libraries)
  foreach(file ${ARGN})
    get_filename_component(fullpath ${file} ABSOLUTE)
    get_filename_component(name ${file} NAME)
    add_custom_target(rosruby_${name}_link ALL
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${fullpath} ${ROSRUBY_DEVEL_LIB_DESTINATION}/${name}
      DEPENDS rosruby_devel_mkdir)
  endforeach()
endmacro()

macro(rosruby_generate_messages)
  add_custom_target(rosruby_genmsg_for_${PROJECT_NAME} ALL
    COMMAND ${ROSRUBY_GENMSG_DIR}/rosruby_genmsg.py ${ARGN}
    -d ${ROSRUBY_DEVEL_LIB_DESTINATION}
    )
  install(DIRECTORY
    ${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/
    DESTINATION ${ROSRUBY_LIB_DESTINATION}
    )
  install(DIRECTORY
    ${ROSRUBY_DEVEL_LIB_DESTINATION}/srv/
    DESTINATION ${ROSRUBY_LIB_DESTINATION}
    )
endmacro()
#
# end macro
#

rosruby_setup()

catkin_add_env_hooks(${PROJECT_NAME} SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)

rosruby_generate_messages(std_msgs rosgraph_msgs roscpp_tutorials)

add_custom_target(rosruby_devel_mkdir ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory ${ROSRUBY_DEVEL_LIB_DESTINATION}
  )


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
