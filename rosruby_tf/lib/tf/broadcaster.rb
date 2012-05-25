require 'ros'
require 'tf/tfMessage'
require 'geometry_msgs/TransformStamped'

module Tf
  class TransformBroadcaster
    def initialize(node)
      @publisher = node.advertise("/tf", TfMessage, :no_resolve=>true)
    end

    def send_transform(translation, rotation, time, child, parent)
      t = Geometry_msgs::TransformStamped.new
      t.header.frame_id = parent
      t.header.stamp = time
      t.child_frame_id = child
      t.transform.translation.x = translation[0]
      t.transform.translation.y = translation[1]
      t.transform.translation.z = translation[2]

      t.transform.rotation.x = rotation[0]
      t.transform.rotation.y = rotation[1]
      t.transform.rotation.z = rotation[2]
      t.transform.rotation.w = rotation[3]

      tfm = TfMessage.new
      tfm.transforms = [t]
      @publisher.publish(tfm)
    end
  end
end
