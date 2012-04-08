module ROS
  module Serializer
    def serialize(message, caller_id, is_latched, topic_name)
      payload = []
      payload.push_back(4)
      payload.push_back(message.get_message_definition_str)

        4 + get_caller_id_str(caller_id).length +
        4 + get_latched_str(is_latched).length +
        4 + message.get_md5sum_str.length +
        4 + get_topic_name(topic_name).length +
        4 + message.get_type_str.length + 
        message.get_serialized_data.length + message.get_serialized_data
      
        
