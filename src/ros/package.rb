module ROS

  class Package
    def initialize(package_name)
      @package_name = package_name
    end

    def self.find_this_package
      path = File::dirname(File.expand_path($PROGRAM_NAME))
      while path != '/'
        if File.exists?("#{path}/manifest.xml")
          return File::basename(path)
        end
        path = File::dirname(path)
      end
      nil
    end

    def add_path_of_package(package)
      IO.popen("rospack find #{package}", 'r') do |iof|
        path = iof.gets[0..-2]
        $:.push("#{path}/msg_gen/ruby")
        $:.push("#{path}/src")
      end
    end

    def add_depend_package_path
      add_path_of_package(@package_name)
      IO.popen("rospack depends #{@package_name}", 'r') do |io|
        while l = io.gets
          add_path_of_package(l[0..-2])
        end
      end
    end
  end
end
