module Std_srvs
  class Empty

    def self.md5sum
      return 'd41d8cd98f00b204e9800998ecf8427e'
    end

    def self.type_string
      return 'std_srvs/Empty'
    end

    class Request

      def serialize()
#        [0].pack("V")
        ''
      end

      def deserialize(data)
        # nothing
      end

    end

    class Response

      def serialize()
        return [0].pack("V")
      end

      def deserialize(data)
        self
      end

    end
  end
end
