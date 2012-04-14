desc "build all messages in local dir."
task :msg_local do
  sh('scripts/gen_for_precompiled.py')
end

desc "clean all messages in local dir."
task :clean_msg_local do
  rm_r(['msg_gen', 'srv_gen'], :force=>true)
end

desc "do all tests"
task :test do
  require 'test/unit'
  test_file = "test/test_*.rb"
  $:.unshift(File.join(File.expand_path("."), "lib"))
  $:.unshift(File.join(File.expand_path("."), "test"))
  Dir.glob(test_file) do |file|
    require file.sub(/\.rb$/, '')
  end
end
