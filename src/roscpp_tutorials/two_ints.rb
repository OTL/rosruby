module Roscpp_tutorials
  class TwoInts
    def self.md5sum
      return '6a2e34150c00229791cc89ff309fff21'
    end

    def self.type_string
      return 'roscpp_tutorials/TwoInts'
    end

    class Request
      attr_accessor :a, :b

      def serialize()
        return [16, @a, @b].pack('Vqq')
      end

      def deserialize(data)
        @a, @b = data.unpack('qq')
        self
      end
    end

    class Response
      attr_accessor :sum

      def serialize()
        return [8, @sum].pack('Vq')
      end

      def deserialize(data)
        @sum = data.unpack('q')[0]
        self
      end
    end
  end
end
