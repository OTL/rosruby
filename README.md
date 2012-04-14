rosruby
=======

I'm a beginner of Ruby.
I start this project to learn Ruby.

ROS is Robot Operating System developed by Willow Garage and open source communities.

Let's start
---------------
Install ROS and ruby first. ROS document is http://ros.org/wiki/ROS/Installation .

You can install ruby by apt.
```bash
$ sudo apt-get install ruby rake
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
packages.

```
$ rosrun rosruby gen_for_precompiled.py
```
This converts msg/srv to .rb which is needed by sample programs.
If you want to make other packages, add package names for args.

For example,

```
$ rosrun rosruby gen_for_precompiled.py geometry_msgs nav_msgs
```


Sample Source
--------------
Subscriber

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

Publisher

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
run publisher sample is

```bash
$ rosrun rosruby sample_publisher.rb
```

run subscription sample

```bash
$ rosrun rosruby sample_publisher.rb
```

do all tests
-------------------------
```bash
$ rosrun rosruby run-test.rb
```
