$:.push("#{File.dirname(__FILE__)}/lib")

namespace :actionlib do
  require 'rubygems'
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb']
  end

  require 'rubygems/package_task'
  actionlib_spec = Gem::Specification.new do |s|
    s.name    = "rosruby_actionlib"
    s.summary = "ROS ruby actionlib"
    s.requirements << 'none'
    s.version = '0.0.1'
    s.author = "Takashi Ogura"
    s.email = "t.ogura@gmail.com"
    s.homepage = "http://github.com/OTL/rosruby"
    s.platform = Gem::Platform::RUBY
    s.files = Dir['lib/**/**', 'samples/**', 'scripts/**/**']
    s.add_development_dependency('rake')
    s.test_files = Dir["test/test*.rb"]
    s.description = "ruby actionlib"
  end

  Gem::PackageTask.new(actionlib_spec).define


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
    Rake::Task["actionlib:test_without_master"].invoke
  end

end
