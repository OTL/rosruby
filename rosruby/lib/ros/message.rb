# ros/message.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# = Message file for msg/srv (de)serialization
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
    def initialize(format)
      @format = format
    end

    def pack(*args)
      args.pack(@format)
    end

    def unpack(arg)
      arg.unpack(@format)
    end

  end
end
