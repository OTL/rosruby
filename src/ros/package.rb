#  package.rb 
#
# $Revision: $
# $Id:$
# $Date:$
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# = ROS Package manager
#
# This is used for adding RUBYLIB path.
# Currently it uses +rospack+ executalbe of ROS.
# I believe that it is better if rospack is removed.
#

module ROS

  class Package
    def initialize(package_name)
      @package_name = package_name
    end

    #
    # get the current program's package
    #
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

    #
    # add package's [src/, msg_gen/ruby, srv_gen/ruby] to '$:'.
    # this enables load ruby files easily
    #
    def add_path_of_package(package)
      `rospack find #{package}`.chop.each do |path|
        ["#{path}/msg_gen/ruby", "#{path}/srv_gen/ruby", "#{path}/src"].each do |path|
          if File.exists?(path)
            $:.push(path)
          end
        end
      end
    end

    #
    # add [src/, msg_gen/ruby, srv_gen/ruby] dirs of all depend packages
    # to RUBYLIB
    #
    def add_path_with_depend_packages
      add_path_of_package(@package_name)
      `rospack depends #{@package_name}`.each do |pack|
        add_path_of_package(pack.chop)
      end
    end
  end
end
