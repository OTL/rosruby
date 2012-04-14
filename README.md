ROS Ruby Client: rosruby
=======

Read latest document on [https://github.com/OTL/rosruby/wiki/rosruby](GitHub Wiki).

I'm a beginner of Ruby.
I start this project to learn Ruby.

[ROS](http://ros.org) is Robot Operating System developed by [Willow Garage](http://www.willowgarage.com/) and open source communities.

Let's start
---------------
Install ROS and ruby first. ROS document is [http://ros.org/wiki/ROS/Installation](http://ros.org/wiki/ROS/Installation) .

You can install ruby by apt.

```bash
$ sudo apt-get install ruby rake
```

Download rosruby into your ROS_PACKAGE_PATH.

````bash
$ git clone git://github.com/OTL/rosruby.git
```

please add RUBYLIB environment variable, like below (if you are using bash).

```bash
$ echo "export RUBYLIB=`rospack find rosruby`/lib" >> ~/.bashrc
$ source ~/.bashrc
```

To use with precompiled electric release
-----------------------
If you are using precompiled ROS distro, use the msg/srv generation script
(gen_for_precompiled.py)
If you are using ROS from source, it requires just recompile the msg/srv
packages by rosmake rosruby.

```bash
$ rosrun rosruby gen_for_precompiled.py
```

This converts msg/srv to .rb which is needed by sample programs.
If you want to make other packages, add package names for args.

For example,

```bash
$ rosrun rosruby gen_for_precompiled.py geometry_msgs nav_msgs
```


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


do all tests
-------------------------
run roscore if is not running.

```bash
$ roscore
```

and run the unit tests.

```bash
$ rosrun rosruby run-test.rb
```

or

```bash
$ roscd rosruby
$ rake test
```
