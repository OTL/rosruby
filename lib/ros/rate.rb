#  rate.rb
#
# $Revision: $
# $Id:$
# $Date:$
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# =Rate
#
#   sleep in a Hz timing.
#
# =Usage
#
#   r = ROS::Rate.new(10)
#   r.sleep
#

module ROS
  class Rate
    def initialize(hz)
      @sleep_duration = 1.0 / hz
      @last_time = ::Time.now
    end

    def sleep
      current_time = ::Time.now
      elapsed = current_time - @last_time
      Kernel.sleep(@sleep_duration - elapsed)
      @last_time = @last_time + @sleep_duration

      # detect time jumping forwards, as well as loops that are
      # inherently too slow
      if current_time - @last_time > @sleep_duration * 2:
          @last_time = current_time
      end
    end
  end
end
