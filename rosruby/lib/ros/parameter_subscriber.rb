# ros/parameter_subscriber.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# = Parameter Subscriber
# callback object for paramUpdate
#
#

module ROS
  class ParameterSubscriber
    def initialize(key, callback)
      @key = key
      @callback = callback
    end

    def call(value)
      @callback.call(value)
    end

    def set_manager(manager)
      @manager = manager
    end

    def shutdown
      @manager.shutdown_parameter_subscriber(self)
    end

    # key of parameter for subscription
    attr_accessor :key

  end
end
