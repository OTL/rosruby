rosruby
=======

I'm a very very beginner of Ruby.
I start this project to learn Ruby.

ROS is Robot Operating System developed by Willow Garage and open source communities.

to use with precompiled electric release
-----------------------
If you are using precompiled ROS distro, use the msg/srv generation script.
If you are using ROS from source, it requires just recompile the msg/srv 
packages.

```
$ rosrun rosruby gen_for_precompiled.py
```

for test
-------------------------
```
$ rosrun rosruby run-test.rb
```

Try Publish and Subscribe
----------------------
run publisher sample is
```
$ rosrun rosruby sample_publisher.rb
```
run subscription sample
```
$ rosrun rosruby sample_publisher.rb
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
sleep(1)

msg = Std_msgs::String.new

i = 0
while node.ok?
  msg.data = "Hello, rosruby!: #{i}"
  publisher.publish(msg)
  sleep(1.0)
  i += 1
end
```