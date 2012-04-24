# ros/duration.rb
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
  # == ROS Duration object
  # This is used as msg object for duration
  class Duration < TimeValue

    # if nsecs is nil, secs is used as float
    #   d1 = ROS::Duration.new(0.1) # => @nsecs=100000000, @secs=0
    #   d2 = ROS::Duration.new(1, 100) # => @nsecs=100, @secs=1
    # [+secs+] seconds
    # [+nsecs+] nano seconds
    def initialize(secs=0, nsecs=nil)
      @secs = secs.to_i
      if nsecs
        @nsecs = nsecs
      else
        @nsecs = ((secs - @secs) * 1e9.to_i).to_i
      end
      canonicalize
    end

    # create a new duration
    # [+duration+] Duration for adding
    def +(duration)
      tm = ::ROS::Duration.new
      tm.secs = @secs + duration.secs
      tm.nsecs = @nsecs + duration.nsecs
      tm.canonicalize
    end

    # create a new duration
    # [+duration+] Duration for substituting
    def -(other)
      d = ::ROS::Duration.new
      d.secs = @secs - other.secs
      d.nsecs = @nsecs - other.nsecs
      d.canonicalize
    end

    # sleep while this duration
    def sleep
      Kernel.sleep(to_sec)
    end
  end

end
