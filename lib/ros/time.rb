# ros/time.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# Time object for ROS.
#

require 'rosgraph_msgs/Clock'

module ROS

  ##
  # super class of times
  class TimeValue

    include Comparable

    # @return [Integer] seconds
    attr_accessor :secs

    # @return [Integer] nano seconds
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
    # @return [Integer] result
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

    # use simulated time?
    @@use_sim_time = false

    # current simulated time
    @@current_sim_time = nil

    # subscriber for /clock
    @@clock_subscriber = nil

    # parameter name for switching sim/wall time.
    SIM_TIME_PARAMETER = '/use_sim_time'

    ##
    # initialize Time
    # @param [Node] node for subscribe /clock.
    def self.initialize_with_sim_or_wall(node)
      @@use_sim_time = node.get_param(SIM_TIME_PARAMETER, false)
      if @@use_sim_time and not @@clock_subscriber
        puts 'initializing simulated clock (/clock)'
        @@clock_subscriber = node.subscribe('/clock',
                                            Rosgraph_msgs::Clock) do |msg|
          @@current_sim_time = msg.clock
        end
        @@sim_thread = Thread.new do
          while node.ok?
            @@clock_subscriber.process_queue
          end
        end
      elsif not @@use_sim_time and @@clock_subscriber
        begin
          @@clock_subscriber.shutdown
        rescue => e
          # even if node is already shutdown, do nothing.
        end
        @@current_sim_time = nil
      end
    end

    ##
    # get the system real time
    # @return [ROS::Time] current time
    def self.get_walltime
      self.new(::Time::now)
    end

    ##
    # get the simulated time
    # @return [ROS::Time] current time in simulator.
    def self.get_simtime
      @@current_sim_time
    end

    # initialize with current time
    def self.now
      if @@current_sim_time
        @@current_sim_time
      else
        self.new(::Time::now)
      end
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
    # @param [Duration] duration duration for adding
    # @return [Time] new time
    def +(duration)
      tm = ::ROS::Time.new
      tm.secs = @secs + duration.secs
      tm.nsecs = @nsecs + duration.nsecs
      tm.canonicalize
    end

    # subtract time value.
    # @param [Time] other
    # @return [Duration] duration
    def -(other)
      d = ::ROS::Duration.new
      d.secs = @secs - other.secs
      d.nsecs = @nsecs - other.nsecs
      d.canonicalize
    end

    # returns ruby Time object.
    # @return [Time] ruby time object
    def to_time
      ::Time.at(@secs, @nsecs)
    end
  end
end
