# ros/service.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# Super Class of ServiceServer and ServiceClient
#

module ROS

  ##
  # Super Class of ServiceServer and ServiceClient
  #
  class Service

    #
    # @param [String] caller_id caller_id of this node
    # @param [String] service_name name of service (String)
    # @param [class] service_type class of Service
    def initialize(caller_id, service_name, service_type)
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
    end

    # @return [String] caller id of this node
    attr_reader :caller_id

    # @return [String] service name (like '/add_two_ints')
    attr_reader :service_name

    # @return [Class] class instance of srv converted class (like Std_msgs/String)
    attr_reader :service_type

  end
end
