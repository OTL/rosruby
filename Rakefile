Dir.glob('**/Rakefile').each{|r| import r}

require 'rubygems/package_task'

rosruby_msgs_spec = Gem::Specification.new do |s|
  s.name    = "rosruby_msgs"
  s.summary = "compiled rosruby msgs/srvs"
  s.requirements << 'none'
  s.version = '0.0.3'
  s.author = "Takashi Ogura"
  s.email = "t.ogura@gmail.com"
  s.homepage = "http://github.com/OTL/rosruby"
  s.platform = Gem::Platform::RUBY
  s.files = Dir['lib/**/**']
  s.add_dependency('rosruby', '>=0.0.1')
  s.description = <<-EOF
rosruby needs msgs/srvs files.
rosruby_msgs provides compiled msgs/srvs files for rosruby.
 EOF
end

Gem::PackageTask.new(rosruby_msgs_spec).define

task :default do
  chdir('rosruby') do
    Rake::Task["rosruby:default"].invoke
  end
end

task :test do
  chdir('rosruby') do
    Rake::Task["rosruby:test"].invoke
  end
end
