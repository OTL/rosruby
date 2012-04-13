module ROS
  
  class TVal

    include Comparable

    attr_accessor :secs, :nsecs

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
    
    def to_sec
      @secs + (@nsecs / 1e9)
    end

    def to_nsec
      @nsecs + (@secs * 1e9)
    end

    
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

  class Time < TVal

    def self.now
      self.new(::Time::now)
    end

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


    def +(duration)
      tm = ::ROS::Time.new
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

  end

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
