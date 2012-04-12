rosbuild_find_ros_package(rosruby)

# Message-generation support.
macro(genmsg_ruby)
  rosbuild_get_msgs(_msglist)
  set(_inlist "")
  set(_autogen "")
  set(genmsg_ruby_exe ${rosruby_PACKAGE_PATH}/scripts/genmsg_ruby.py)

  foreach(_msg ${_msglist})
    # Construct the path to the .msg file
    set(_input ${PROJECT_SOURCE_DIR}/msg/${_msg})
    # Append it to a list, which we'll pass back to gensrv below
    list(APPEND _inlist ${_input})
  
    rosbuild_gendeps(${PROJECT_NAME} ${_msg})
  

    set(_output_ruby ${PROJECT_SOURCE_DIR}/msg_gen/ruby/${PROJECT_NAME}/${_msg})
    string(REPLACE ".msg" ".rb" _output_ruby ${_output_ruby})
  
    # Add the rule to build the .rb from the .msg.
    add_custom_command(OUTPUT ${_output_ruby} 
                       COMMAND ${genmsg_ruby_exe} ${_input}
                       DEPENDS ${_input} ${genmsg_ruby_exe} ${gendeps_exe} ${${PROJECT_NAME}_${_msg}_GENDEPS} ${ROS_MANIFEST_LIST})
    list(APPEND _autogen ${_output_ruby})
  endforeach(_msg)

  if(_autogen)
    add_custom_target(ROSBUILD_genmsg_ruby DEPENDS ${_autogen})
    # A target that depends on generation of the __init__.py
    add_custom_target(ROSBUILD_genmsg_ruby DEPENDS ${_output_ruby})
    # Make our target depend on rosbuild_premsgsrvgen, to allow any
    # pre-msg/srv generation steps to be done first.
    add_dependencies(ROSBUILD_genmsg_ruby rosbuild_premsgsrvgen)
    # Add our target to the top-level genmsg target, which will be fired if
    # the user calls genmsg()
    add_dependencies(rospack_genmsg ROSBUILD_genmsg_ruby)

    # Also set up to clean the src/<project>/msg directory
    get_directory_property(_old_clean_files ADDITIONAL_MAKE_CLEAN_FILES)
    set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${_old_clean_files}")
  endif(_autogen)
endmacro(genmsg_ruby)

# Call the macro we just defined.
genmsg_ruby()

# Service-generation support.
macro(gensrv_ruby)
  rosbuild_get_srvs(_srvlist)
  set(_inlist "")
  set(_autogen "")
  set(gensrv_ruby_exe ${rosruby_PACKAGE_PATH}/scripts/gensrv_ruby.py)

  foreach(_srv ${_srvlist})
    # Construct the path to the .srv file
    set(_input ${PROJECT_SOURCE_DIR}/srv/${_srv})
    # Append it to a list, which we'll pass back to gensrv below
    list(APPEND _inlist ${_input})
  
    rosbuild_gendeps(${PROJECT_NAME} ${_srv})
  
    set(_output_ruby ${PROJECT_SOURCE_DIR}/srv_gen/ruby/${PROJECT_NAME}/${_srv})
    string(REPLACE ".srv" ".rb" _output_ruby ${_output_ruby})
  
    # Add the rule to build the .rb from the .srv
    add_custom_command(OUTPUT ${_output_ruby} 
                       COMMAND ${gensrv_ruby_exe} ${_input}
                       DEPENDS ${_input} ${gensrv_ruby_exe} ${gendeps_exe} ${${PROJECT_NAME}_${_srv}_GENDEPS} ${ROS_MANIFEST_LIST})
    list(APPEND _autogen ${_output_ruby})
  endforeach(_srv)

  if(_autogen)
    add_custom_target(ROSBUILD_gensrv_cpp DEPENDS ${_autogen})
    # A target that depends on generation
    add_custom_target(ROSBUILD_gensrv_ruby DEPENDS ${_output_ruby})
    # Make our target depend on rosbuild_premsgsrvgen, to allow any
    # pre-msg/srv generation steps to be done first.
    add_dependencies(ROSBUILD_gensrv_ruby rosbuild_premsgsrvgen)
    # Add our target to the top-level gensrv target, which will be fired if
    # the user calls gensrv()
    add_dependencies(rospack_gensrv ROSBUILD_gensrv_ruby)

    # Also set up to clean the src/<project>/srv directory
    get_directory_property(_old_clean_files ADDITIONAL_MAKE_CLEAN_FILES)
    set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${_old_clean_files}")
  endif(_autogen)
endmacro(gensrv_ruby)

# Call the macro we just defined.
gensrv_ruby()

