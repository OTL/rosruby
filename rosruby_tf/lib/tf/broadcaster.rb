require 'ros'
require 'tf/tfMessage'
require 'geometry_msgs/TransformStamped'

module Tf

  class TransformBroadcaster

    def initialize(node)
      @publisher = node.advertise("/tf", TfMessage, :no_resolve=>true)
    end

    def send_transform(translation, rotation, time, child, parent)
      ts_msg = Geometry_msgs::TransformStamped.new
      ts_msg.header.frame_id = parent
      ts_msg.header.stamp = time
      ts_msg.child_frame_id = child
      ts_msg.transform.translation.x = translation[0]
      ts_msg.transform.translation.y = translation[1]
      ts_msg.transform.translation.z = translation[2]

      ts_msg.transform.rotation.x = rotation[0]
      ts_msg.transform.rotation.y = rotation[1]
      ts_msg.transform.rotation.z = rotation[2]
      ts_msg.transform.rotation.w = rotation[3]

      tfm = TfMessage.new
      tfm.transforms = [ts_msg]
      @publisher.publish(tfm)
    end

  end
end
