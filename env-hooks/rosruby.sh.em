@[if DEVELSPACE]@
# env variables in develspace
export RUBYLIB="@(CATKIN_DEVEL_PREFIX)/@(CATKIN_GLOBAL_LIB_DESTINATION)/ruby/vendor_ruby":"$RUBYLIB"
@[else]@
# env variables in installspace
export RUBYLIB="$CATKIN_ENV_HOOK_WORKSPACE/@(CATKIN_GLOBAL_LIB_DESTINATION)/ruby/vendor_ruby":"$RUBYLIB"
@[end if]@
