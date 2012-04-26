# ros/time.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# Time object for ROS.
#
module ROS

  ##
  # super class of times
  class TimeValue

    include Comparable

    # @return [Fixnum] seconds
    attr_accessor :secs

    # @return [Fixnum] nano seconds
    attr_accessor :nsecs

    # canonicalize secs and nsecs
    # @return [TimeValue] self
    def canonicalize
      while @nsecs >= 1e9.to_i
        @secs += 1
        @nsecs -= 1e9.to_i
      end
      while @nsecs < 0
        @secs -= 1
        @nsecs += 1e9.to_i
      end
      self
    end

    # convert to seconds
    # @return [Float] seconds
    def to_sec
      @secs + (@nsecs / 1e9)
    end

    # convert to nano seconds
    # @return [Float] nano seconds
    def to_nsec
      @nsecs + (@secs * 1e9)
    end

    # compare time value
    # @param [TimeValue] other compare target
    # @return [Fixnum] result
    def <=>(other)
      diff = self.to_nsec - other.to_nsec
      if diff > 0
        1
      elsif diff < 0
        -1
      else
        0
      end
    end

  end

  ##
  # ROS Time object. This is used as msg object for time
  #
  class Time < TimeValue

    # initialize with current time
    def self.now
      self.new(::Time::now)
    end

    # @overload initialize(time)
    #   @param [::Time] initialize with this time
    # @overload initialize
    def initialize(time=nil)
      if time
        @secs = time.to_i
        @nsecs = ((time.to_f - @secs) * 1e9.to_i).to_i
      else
        @secs = 0
        @nsecs = 0
      end
      canonicalize
    end

    # add time value
    # @param [Duration]
    # @return [Time] new time
    def +(duration)
      tm = ::ROS::Time.new
      tm.secs = @secs + duration.secs
      tm.nsecs = @nsecs + duration.nsecs
      tm.canonicalize
    end

    # subtract time value
    # @param [Time] other
    # @return [Duration] duration
    def -(other)
      d = ::ROS::Duration.new
      d.secs = @secs - other.secs
      d.nsecs = @nsecs - other.nsecs
      d.canonicalize
    end
  end
end
