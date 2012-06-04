# ros/message.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# == Message file for msg/srv (de)serialization
#
#

module ROS

  ##
  # super class of all msg/srv converted class.
  # Currently this is none.
  class Message
  end

  ##
  # used for serialization (for python like grammar)
  # this is used by msg/srv converted *.rb files
  # it can be removed, if there are more effective genmsg_ruby.
  class Struct

    # @param [String] format
    def initialize(format)
      @format = format
    end

    ##
    # get the format string.
    # @return [String] format string.
    attr_reader :format

    ##
    # Calc the size
    # @param [String] format format string to calculate.
    # @return [Integer] size of this format (byte).
    def self.calc_size(format)
      array = []
      start = 0
      while start < format.length
        re = /(\w)(\d*)/
        re =~ format[start..(format.length-1)]
        number = $2.to_i
        if number == 0
          array.push(0)
        else
          for i in 1..number
            array.push(0)
          end
        end
        start += $&.length
      end
      array.pack(format).length
    end

    # pack the data
    # @param [Array] args
    def pack(*args)
      args.pack(@format)
    end

    # unpack from string
    # @param [String] arg
    # @return [Array] unpacked data
    def unpack(arg)
      arg.unpack(@format)
    end

  end
end
