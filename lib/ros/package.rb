# ros/package.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# == ROS Package manager
#
# This is used for adding RUBYLIB path.
# This file will provide rospack functions, in the future
#

require 'rexml/document'

module ROS

  # This is used for adding RUBYLIB path.
  #
  class Package

    ##
    # at first check the rospack's cache, if found use it.
    # if not found, check all package path.
    # @param [String] cache_file cache file of rospack
    # @return [Array] fullpath list of all packages
    def self.read_cache_or_find_all(cache_file="#{ENV['HOME']}/.ros/rospack_cache")
      if File.exists?(cache_file)
        f = File.open(cache_file)
        root_line = f.gets.chop
        package_path_line = f.gets.chop
        if root_line == "#ROS_ROOT=#{ENV['ROS_ROOT']}" and
            package_path_line == "#ROS_PACKAGE_PATH=#{ENV['ROS_PACKAGE_PATH']}"
          packages = {}
          while line = f.gets
            packages[File.basename(line.chop)] = line.chop
          end
          packages
        else
          self.find_all_packages
        end
      else
        self.find_all_packages
      end
    end

    ##
    # search all packages that has manifest.xml
    # @param [Hash] packages current found packages
    # @param [Array] roots root directories for searching
    # @return [Array] fullpath list of all packages
    def self.find_all_packages(packages={}, roots=[])
      if roots.empty?
        if ENV['ROS_PACKAGE_PATH']
          roots = ENV['ROS_PACKAGE_PATH'].split(':')
        else
          puts 'Waring: ROS_PACKAGE_PATH is not set'
        end
        if ENV['ROS_ROOT']
          roots.push(ENV['ROS_ROOT'])
        else
          puts 'Waring: ROS_ROOT is not set'
        end
      end
        
      roots.each do |root|
        if File.exists?("#{root}/manifest.xml") or 
            File.exists?("#{root}/package.xml")
          packages[File.basename(root)] = root
        else
          if File.exists?(root)
            Dir.foreach(root) do |path|
              if path != "." and path != ".."
                full_path = "#{root}/#{path}"
                if File.directory?(full_path)
                  self.find_all_packages(packages, [full_path])
                end
              end
            end
          end
        end
      end
      packages
    end

    ##
    # all package path hash
    #
    @@all_packages = self.read_cache_or_find_all

    ##
    # get the depend packages of the arg
    # @param [String] package find depends packages of this package
    # @param [Array] packages current found depends
    # @return [Array] packages
    def self.depends(package, packages=[])
      begin
        if File.exists?("#{@@all_packages[package]}/manifest.xml")
          file = File.open("#{@@all_packages[package]}/manifest.xml")
          doc = REXML::Document.new(file)
          doc.elements.each('/package/depend') do |element|
            depend_package = element.attributes['package']
            if not packages.include?(depend_package)
              packages.push(depend_package)
              self.depends(depend_package, packages)
            end
          end
        else
          file = File.open("#{@@all_packages[package]}/package.xml")
          doc = REXML::Document.new(file)
          doc.elements.each('/package/run_depend') do |element|
            depend_package = element.text
            if not packages.include?(depend_package)
              packages.push(depend_package)
              self.depends(depend_package, packages)
            end
          end
        end
      rescue
#        puts "#{package}'s manifest.xml/package.xml not found"
      end
      packages
    end


    ##
    # get the current program's package
    # @return [String] name of running programs's package
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

    ##
    # add package's [lib/, msg_gen/ruby, srv_gen/ruby] to '$:'.
    # this enables load ruby files easily
    # @param [String] package name of package
    def self.add_path_of_package(package)
      path = @@all_packages[package]
      ["#{path}/msg_gen/ruby", "#{path}/srv_gen/ruby", "#{path}/lib"].each do |path|
        if File.exists?(path)
          if not $:.include?(path)
            $:.push(path)
          end
        end
      end
    end

    ##
    # add [lib/, msg_gen/ruby, srv_gen/ruby] dirs of all depend packages
    # to RUBYLIB, if the directory exists
    # @param [String] package name of package
    def self.add_path_with_depend_packages(package)
      add_path_of_package(package)
      Package::depends(package).each do |pack|
        add_path_of_package(pack)
      end
    end
  end

  ##
  # load manifest and add all dependencies
  # @param [String] package name of package
  def self.load_manifest(package)
    ROS::Package.add_path_with_depend_packages(package)
  end
end
