require 'ros'
require 'tf/transformer'
require 'tf/tfMessage'
require 'geometry_msgs/TransformStamped'

module Tf
  class TransformListener
    def initialize(node)
      @transform_buffer = TransformBuffer.new
      @subscriber = node.subscribe("/tf", TfMessage) do |tf_msg|
        tf_msg.transforms.each do |tf|
          parent = @transform_buffer.find_transform(tf.header.frame_id,
                                                    tf.header.stamp)

          transform = Transform.new(tf.child_frame,
                                    [tf.transform.translation.x,
                                     tf.transform.translation.y,
                                     tf.transform.translation.z],
                                    [tf.transform.rotation.x,
                                     tf.transform.rotation.y,
                                     tf.transform.rotation.z,
                                     tf.transform.rotation.w],
                                    parent)
          tranform.stamp = tf.header.stamp
          @transformer.add_transform(tranform)
        end
      end
      @thread = Thread.new do
        while node.ok?
          sleep 0.1
          @subscriber.process_queue
        end
      end
    end

    def lookup_transform(from_id, to_id, stamp)
      from = @transform_buffer.find_transform(from_id, stamp)
      to = @transform_buffer.find_transform(to_id, stamp)
      from.get_transform_to(to)
    end

    def shutdown
      if not @thread.join(0.1)
        Thread::kill(@thread)
      end
    end

  end
end
