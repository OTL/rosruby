^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package rosruby
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.5.0 (2013-10-02)
------------------
* delete samples (please use rosruby_tutorials package)
* use genrb package

0.4.3 (2013-09-11)
------------------
* set ROS_ROOT environ if it is not set for roslib.package (it requires it)

0.4.2 (2013-09-11)
------------------
* add more depends

0.4.1 (2013-09-10)
------------------
* remove rosrun from message generation for rosruby
* add import roslib and build_depend roslib in package.xml

0.4.0 (2013-09-10)
-------------------
* use catkin_add_hook for ROSLIB environment
* color local log like rospy/roscpp
  * ERROR/FATAL => red
  * WARN => yellow
* wait until master connection
* change genmsg output dir to catkin lib dir

0.3.0 (2013-09-05)
-------------------
* catkinized

v0.2.1
-----------
* move libraries ``rosruby_common``, actionlib, tf to other repositories.
* bug fix of message deserialization of array with size(#32).

v0.2.0
-----------
* add some libraries

v0.1.1
------------
* first stable release
