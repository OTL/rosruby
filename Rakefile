$:.push("#{File.dirname(__FILE__)}/lib")

task :default => :msg_local

message_dir = "#{ENV['HOME']}/.ros/rosruby"

desc "generate all messages in local dir"
task :msg_local => message_dir

require 'rake/clean'
CLEAN << 'doc'
CLEAN << message_dir

require 'rubygems'
require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.options = ['--readme', 'README.md']
end

require 'rubygems/package_task'
rosruby_spec = Gem::Specification.new do |s|
  s.name    = "rosruby"
  s.summary = "ROS ruby client"
  s.requirements << 'none'
  s.version = '0.0.1'
  s.author = "Takashi Ogura"
  s.email = "t.ogura@gmail.com"
  s.homepage = "http://github.com/OTL/rosruby"
  s.platform = Gem::Platform::RUBY
  s.files = Dir['lib/**/**', 'samples/**', 'scripts/**/**']
  s.executables = ['rubyroscore']
  s.add_development_dependency('rake')
  s.test_files = Dir["test/test*.rb"]
  s.description = File.read("README.md")
end

Gem::PackageTask.new(rosruby_spec).define

desc "Generate precompiled msg gem"
task :msg_gem do
  target_msg_packages = "actionlib_msgs pr2_controllers_msgs std_msgs visualization_msgs actionlib_tutorials roscpp stereo_msgs geometry_msgs rosgraph_msgs tf nav_msgs sensor_msgs trajectory_msgs std_srvs"
  system("scripts/rosruby_genmsg.py #{target_msg_packages}")
  mkdir_p('msg_gem/lib')
  cp_r(Dir.glob("#{ENV['HOME']}/.ros/rosruby/msg_gen/ruby/*"), "msg_gem/lib/")
  cp_r(Dir.glob("#{ENV['HOME']}/.ros/rosruby/srv_gen/ruby/*"), "msg_gem/lib/")
  chdir('msg_gem') do
    namespace :msg do
      msg_spec = Gem::Specification.new do |s|
        s.name    = "rosruby_msgs"
        s.summary = "rosruby's basic msg/srv"
        s.requirements << 'none'
        s.version = '0.0.4'
        s.author = "Takashi Ogura"
        s.email = "t.ogura@gmail.com"
        s.homepage = "http://github.com/OTL/rosruby"
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = false
        s.files = Dir['lib/**/**']
        s.description = "precompiled msg files for rosruby."
      end
      Gem::PackageTask.new(msg_spec).define
    end
    Rake::Task["msg:package"].invoke
  end
end

desc "generate all messages in local dir."
file message_dir do |file|
  sh('scripts/rosruby_genmsg.py')
end

require 'rake/testtask'
Rake::TestTask.new(:test_without_master) do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc "test with roscore"
task :test do
  require "ros/roscore"
  thread = Thread.new do
    ROS::start_roscore
  end
  ROS::wait_roscore
  Rake::Task["test_without_master"].invoke
  Thread.kill(thread)
end
