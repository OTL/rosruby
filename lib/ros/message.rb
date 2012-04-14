#  message.rb
#
# $Revision: $
# $Id:$
# $Date:$
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# = Message file for msg/srv (de)serialization
#
# 

module ROS

  ##
  # super class of all msg/srv converted class
  #
  class Message
  end

  ##
  # used for serialization (for python like grammar)
  # 
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
