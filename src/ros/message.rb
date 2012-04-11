module ROS
  class Message
  end

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
