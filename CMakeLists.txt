cmake_minimum_required(VERSION 2.8.3)
project(rosruby)

find_package(catkin REQUIRED COMPONENTS roslib rosgraph_msgs std_msgs roscpp_tutorials)

catkin_package(
  CATKIN_DEPENDS roslang rosgraph_msgs roslib std_msgs roscpp_tutorials
  DEPENDS ruby
)


#
# macro definitions
#
macro(rosruby_setup)
  set(ROSRUBY_DEVEL_LIB_DESTINATION ${CATKIN_DEVEL_PREFIX}/lib/ruby/vendor_ruby)
  set(ROSRUBY_LIB_DESTINATION ${CATKIN_GLOBAL_LIB_DESTINATION}/ruby/vendor_ruby)
  set(ROSRUBY_GENMSG ${ROSRUBY_DEVEL_LIB_DESTINATION}/rosruby_genmsg.py)
  foreach(prefix ${CMAKE_PREFIX_PATH})
    if(EXISTS ${prefix}/${CATKIN_GLOBAL_LIB_DESTINATION}/rosruby/rosruby_genmsg.py)
      set(ROSRUBY_GENMSG ${prefix}/${CATKIN_GLOBAL_LIB_DESTINATION}/rosruby/rosruby_genmsg.py)
    endif()
  endforeach()
  message("-- using ${ROSRUBY_GENMSG} for message generation")
endmacro()

macro(rosruby_generate_messages)
  foreach(pkg ${ARGN})
    add_custom_command(
      OUTPUT ${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/${pkg}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/${pkg}
      COMMAND ${ROSRUBY_GENMSG} -d ${ROSRUBY_DEVEL_LIB_DESTINATION} ${pkg}
      DEPENDS rosruby_devel_mkdir)
    add_custom_target(rosruby_genmsg_${pkg} ALL
      DEPENDS ${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/${pkg})
  endforeach()
  install(DIRECTORY ${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/
    DESTINATION ${ROSRUBY_LIB_DESTINATION}/msg
    )
  install(DIRECTORY ${ROSRUBY_DEVEL_LIB_DESTINATION}/srv/
    DESTINATION ${ROSRUBY_LIB_DESTINATION}/srv
    )
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
#
# end macro
#

rosruby_setup()

catkin_add_env_hooks(rosruby SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)
rosruby_generate_messages(rosgraph_msgs std_msgs roscpp_tutorials)

add_custom_target(rosruby_devel_mkdir ALL
  COMMAND ${CMAKE_COMMAND} -E make_directory ${ROSRUBY_DEVEL_LIB_DESTINATION}
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/scripts/genmsg_ruby.py ${ROSRUBY_DEVEL_LIB_DESTINATION}
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/scripts/gensrv_ruby.py ${ROSRUBY_DEVEL_LIB_DESTINATION}
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/scripts/rosruby_genmsg.py ${ROSRUBY_DEVEL_LIB_DESTINATION})

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

rosruby_add_libraries(
  lib/ros.rb
  lib/ros)

install(DIRECTORY lib/
  DESTINATION ${ROSRUBY_LIB_DESTINATION}
  )
