$:.push("#{File.dirname(__FILE__)}/lib")

namespace :tf do
  require 'rubygems'
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb']
  end

  require 'rubygems/package_task'
  tf_spec = Gem::Specification.new do |s|
    s.name    = "rosruby_tf"
    s.summary = "ROS ruby TF"
    s.requirements << 'none'
    s.version = '0.0.1'
    s.author = "Takashi Ogura"
    s.email = "t.ogura@gmail.com"
    s.homepage = "http://github.com/OTL/rosruby"
    s.platform = Gem::Platform::RUBY
    s.files = Dir['lib/**/**', 'samples/**', 'scripts/**/**']
    s.add_development_dependency('rake')
    s.test_files = Dir["test/test*.rb"]
    s.description = "ruby tf"
  end

  Gem::PackageTask.new(tf_spec).define


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
    Rake::Task["tf:test_without_master"].invoke
  end

end
