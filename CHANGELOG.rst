^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package rosruby
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
