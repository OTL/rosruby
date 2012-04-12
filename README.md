rosruby
=======

I'm a very very beginner of Ruby.
I start this project to learn Ruby.

ROS is Robot Operating System developed by Willow Garage and open source communities.

to use with electric release
=========================
If you are using precompiled ROS distro, please compile msg/srv packages you need. for example...

```
$ roscd rosgraph_msgs
$ sudo chmod 777 .
$ sudo chmod 777 msg_gen
$ make

$ roscd std_msgs
$ sudo chmod 777 .
$ sudo chmod 777 msg_gen
$ make
```
