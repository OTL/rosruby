^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package rosruby
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

0.5.5 (2013-10-25)
------------------
* add path for message generation (msg and srv)

0.5.4 (2013-10-19)
------------------
* add genrb_pkg.sh again, because binary build fails.

0.5.3 (2013-10-19)
------------------
* remove shell script and use CATKIN_ENV
* add message_generation depends and add mkdir in macro
* add genmsg for depends
* add python executable

0.5.2 (2013-10-03)
------------------
* add setup.py for resolve genrb
* use genrb_pkg_sh for message generation
  (because in binary environment, we have to source setup.sh)

0.5.1 (2013-10-02)
------------------
* change msg/srv generation path.
  it will be same as genrb.
* export rosruby macros

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
