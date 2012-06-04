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
