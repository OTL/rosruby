# ros/service.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# = Service
# Super Class of ServiceServer and ServiceClient
#

module ROS

  ##
  # Super Class of ServiceServer and ServiceClient
  #
  class Service

    def initialize(caller_id, service_name, service_type)
      @caller_id = caller_id
      @service_name = service_name
      @service_type = service_type
      @host = "localhost"
    end

    attr_reader :caller_id

    # service name (like '/add_two_ints')
    attr_reader :service_name

    # class instance of srv converted class (like Std_msgs/String)
    attr_reader :service_type

  end
end
