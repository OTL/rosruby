require 'ros'
require 'tf/tfMessage'
require 'geometry_msgs/TransformStamped'

module Tf
  class TransformListener
    def initialize(node)
      @subscriber = node.subscribe("/tf", TfMessage) do |tf|

      end
      @thread = Thread.new do
        while node.ok?
          sleep 0.1
          @subscriber.process_queue
        end
      end
    end

    def shutdown
      if not @thread.join(0.1)
        Thread::kill(@thread)
      end
    end

  end
end
