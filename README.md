ROS Ruby Client: rosruby
=======
[ROS](http://ros.org) is Robot Operating System developed by [OSRF](http://osrfoundation.org/) and open source communities.

This project supports ruby ROS client. You can program intelligent robots by ruby, very easily.

**Homepage**:     http://otl.github.com/rosruby   
**Git**:          http://github.com/OTL/rosruby   
**Author**:       Takashi Ogura   
**Copyright**:    2012   
**License**:      new BSD License   
**Latest Version**: 0.3.0   

Requirements
----------
- ruby (1.8.7/1.9.3)
- ROS (groovy)

electric/fuerte
---------
If you are using electric or fuerte, please use v0.2.1.

Install from source
---------------
Install ROS and ruby first. ROS document is [http://ros.org/wiki/ROS/Installation](http://ros.org/wiki/ROS/Installation) .

Please use catkin to install rosruby.
If you have not catkin_ws yet, please read [this wiki](http://wiki.ros.org/ROS/Tutorials/InstallingandConfiguringROSEnvironment).

````bash
$ cd ~/catkin_ws/src
$ git clone git://github.com/OTL/rosruby.git
$ cd ~/catkin_ws
$ catkin_make
```

please add RUBYLIB environment variable, like below (if you are using bash).

```bash
$ echo "export RUBYLIB=`rospack find rosruby`/lib" >> ~/.bashrc
$ source ~/.bashrc
```

If you are using install environment for catkin....(advanced)
---------------------------------------------------------------
if you want to use rosruby in `install` environment,
this means you are doing like this.

```bash
$ catkin_make install
$ source ~/catkin_ws/install/setup.bash
```

then you must use below RUBYLIB environment.

```bash
export RUBYLIB=~/catkin_ws/install/lib/ruby
```

Message generation
-----------------------
You must generate ROS msg/srv files for rosruby manually.
Please use the msg/srv generation script (rosruby_genmsg.py) in order to 
generage rosruby messages.

For example,

```bash
$ rosrun rosruby rosruby_genmsg.py geometry_msgs nav_msgs
```

Arguments are msg package names. If arguments are not given,
that converts msg/srv to .rb which is needed by sample programs.

This generates message files in ~/.ros/rosruby directory.

Sample Source
--------------

## Subscriber

```ruby
#!/usr/bin/env ruby

require 'ros'
require 'std_msgs/String'

node = ROS::Node.new('/rosruby/sample_subscriber')
node.subscribe('/chatter', Std_msgs::String) do |msg|
  puts "message come! = \'#{msg.data}\'"
end

while node.ok?
  node.spin_once
  sleep(1)
end

```

## Publisher

```ruby
#!/usr/bin/env ruby

require 'ros'
require 'std_msgs/String'

node = ROS::Node.new('/rosruby/sample_publisher')
publisher = node.advertise('/chatter', Std_msgs::String)

msg = Std_msgs::String.new

i = 0
while node.ok?
  msg.data = "Hello, rosruby!: #{i}"
  publisher.publish(msg)
  sleep(1.0)
  i += 1
end
```

Note
----------------
Ruby requires 'Start with Capital letter' for class or module names.
So please use **S**td_msgs::String class instead of **s**td_msgs::String.

Try Publish and Subscribe
----------------------
You needs three terminal as it is often for ROS users.
Then you run roscore if is not running.

```bash
$ roscore
```

run publisher sample

```bash
$ rosrun rosruby sample_publisher.rb
```

run subscription sample

```bash
$ rosrun rosruby sample_subscriber.rb
```

you can check publication by using rostopic.

```bash
$ rostopic list
$ rostopic echo /chatter
```

Try Service?
----------------------

```bash
$ rosrun rosruby add_two_ints_server.rb
```

run client with args ('a' and 'b' for roscpp_tutorials/TwoInts)

```bash
$ rosrun rosruby add_two_ints_client.rb 10 20
```

And more...
----------------------
There are [rosruby_common](https://github.com/OTL/rosruby_common) stack that contains actionlib and tf (highly under development).

Do all tests
-------------------------

[![Build Status](https://secure.travis-ci.org/OTL/rosruby.png)](http://travis-ci.org/OTL/rosruby)

Install some packages for tests.

```bash
$ sudo apt-get install rake gem
$ sudo gem install yard redcarpet simplecov
```

run tests.

```bash
$ roscd rosruby
$ rake test
```

Documents
--------------------------
you can generate API documents using yard.
Document generation needs yard and redcarpet.
You can install these by gem command like this.

```bash
$ gem install yard redcarpet
```

Then try to generate documentds.

```bash
$ rake yard
```

You can access to the generated documents from [here](http://otl.github.com/rosruby/doc/).
