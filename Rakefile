Dir.glob('**/Rakefile').each{|r| import r}

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
