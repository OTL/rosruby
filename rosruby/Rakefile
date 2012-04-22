task :default => :msg_local

task :clean => :clean_msg_local do
  rm_r(['doc'], :force=>true)
end

desc "generate rudy docs"
task :doc => :clean do
  sh('rdoc -m ROS::Node')
end

desc "build all messages in local dir."
task :msg_local do
  sh('scripts/gen_for_precompiled.py')
end

desc "clean all messages in local dir."
task :clean_msg_local do
  rm_r(['msg_gen', 'srv_gen'], :force=>true)
end

if RUBY_VERSION >= '1.9.0'
  require 'rake/gempackagetask'

  spec = Gem::Specification.new do |s|
    s.name = "rosruby"
    s.summary = "ROS ruby client"
    s.description = File.read(File.join(File.dirname(__FILE__), 'README.md'))
    s.requirements = ['ROS installed']
    s.version = "0.1.2"
    s.author = "Takashi Ogura"
    s.email = "t.ogura@gmail.com"
    s.homepage = "http://github.com/OTL/rosruby"
    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = '>=1.8'
    s.files = Dir['**/**']
    s.executables = []
    s.test_files = Dir["test/test*.rb"]
    s.has_rdoc = true
  end

  Rake::GemPackageTask.new(spec).define
end

desc "do all tests"
task :test do
  require 'test/unit'
  $:.push(File.dirname(__FILE__))
  test_file = "test/test_*.rb"
  $:.unshift(File.join(File.expand_path("."), "lib"))
  $:.unshift(File.join(File.expand_path("."), "test"))
  Dir.glob(test_file) do |file|
    require file.sub(/\.rb$/, '')
  end
end
