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
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${fullpath} ${ROSRUBY_DEVEL_LIB_DESTINATION}/${name})
  endforeach()
endmacro()

macro(rosruby_generate_messages)
  add_custom_target(rosruby_genmsg_for_${PROJECT_NAME} ALL
    COMMAND ${ROSRUBY_GENMSG_DIR}/rosruby_genmsg.py ${ARGN}
    -d ${ROSRUBY_DEVEL_LIB_DESTINATION}
    )
  foreach(package ${ARGN})
    if(EXISTS ${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/${package})
      install(DIRECTORY
	${ROSRUBY_DEVEL_LIB_DESTINATION}/msg/${package}
	DESTINATION ${ROSRUBY_LIB_DESTINATION}
	)
    endif()
    if(EXISTS ${ROSRUBY_DEVEL_LIB_DESTINATION}/srv/${package})
      install(DIRECTORY
	${ROSRUBY_DEVEL_LIB_DESTINATION}/srv/${package}
	DESTINATION ${ROSRUBY_LIB_DESTINATION}
	)
    endif()
  endforeach()
endmacro()
