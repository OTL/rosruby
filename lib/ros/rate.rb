# ros/rate.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
#

require 'ros/time'

module ROS

  ##
  # sleep in a Hz timing.
  # @example
  #   r = ROS::Rate.new(10)
  #   r.sleep
  #
  class Rate

    # @param [Float] hz Hz
    def initialize(hz)
      @sleep_duration = ::ROS::Duration.new(1.0 / hz)
      @last_time = ::ROS::Time.now
    end

    ##
    # sleep for preset rate [Hz]
    #
    def sleep
      current_time = ::ROS::Time.now
      if @last_time > current_time
        @last_time = current_time
      end
      elapsed = current_time - @last_time
      time_to_sleep = @sleep_duration - elapsed
      if time_to_sleep.to_sec > 0.0
        time_to_sleep.sleep
      end
      @last_time = @last_time + @sleep_duration

      # detect time jumping forwards, as well as loops that are
      # inherently too slow
      if (current_time - @last_time).to_sec > @sleep_duration.to_sec * 2
        @last_time = current_time
      end
      nil
    end
  end
end
