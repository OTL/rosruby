module ROS
  class Time
    def self.now
      self.new(::Time::now)
    end

    def initialize(time=nil)
      if time
        @secs = time.to_i
        @nsecs = ((time.to_f - @secs) * 1000000000).to_i
      else
        @secs = 0
        @nsecs = 0
      end
    end

    attr_accessor :secs, :nsecs

  end
end
