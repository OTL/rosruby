@[if DEVELSPACE]@
# location of scripts in develspace
set(ROSRUBY_GENMSG_DIR "@(CMAKE_CURRENT_SOURCE_DIR)/scripts")
@[else]@
# location of scripts in installspace
set(ROSRUBY_GENMSG_DIR "${rosruby_DIR}/../../../@(CATKIN_PACKAGE_BIN_DESTINATION)")
@[end if]@

