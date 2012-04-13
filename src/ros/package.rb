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
      `rospack find #{package}`.chop.each do |path|
        ["#{path}/msg_gen/ruby", "#{path}/srv_gen/ruby", "#{path}/src"].each do |path|
          if File.exists?(path)
            $:.push(path)
          end
        end
      end
    end

    def add_depend_package_path
      add_path_of_package(@package_name)
      `rospack depends #{@package_name}`.each do |pack|
        add_path_of_package(pack.chop)
      end
    end
  end
end
