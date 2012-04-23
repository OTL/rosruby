# ros/time.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# Duration object for ROS.
#

require 'ros/time'

module ROS

  ##
  # ROS Duration object. This is used as msg object for duration
  #
  class Duration < TVal

    def initialize(secs=0, nsecs=nil)
      @secs = secs.to_i
      if nsecs
        @nsecs = nsecs
      else
        @nsecs = ((secs - @secs) * 1e9.to_i).to_i
      end
      canonicalize
    end

    def +(duration)
      tm = ::ROS::Duration.new
      tm.secs = @secs + duration.secs
      tm.nsecs = @nsecs + duration.nsecs
      tm.canonicalize
    end

    def -(other)
      d = ::ROS::Duration.new
      d.secs = @secs - other.secs
      d.nsecs = @nsecs - other.nsecs
      d.canonicalize
    end

    def sleep
      Kernel.sleep(to_sec)
    end
  end

end
