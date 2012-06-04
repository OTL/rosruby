# ros/parameter_subscriber.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#
# == Parameter Subscriber
# callback object for paramUpdate
#
#

module ROS

  # callback object for paramUpdate
  #
  class ParameterSubscriber
    # do not make instance directory. Plese use Node#subscribe_parameter.
    # @param [String] key param key to subscribe
    # @param [Proc] callback callback when parameter updated
    def initialize(key, callback)
      @key = key
      @callback = callback
    end

    # callback with param value
    # @param [String] value value of updated parameter
    def call(value)
      @callback.call(value)
    end

    # set GraphManager for management
    # @param [GraphManager] manager GraphManager
    def set_manager(manager) #:nodoc
      @manager = manager
    end

    # shutdown this subscription
    def shutdown
      @manager.shutdown_parameter_subscriber(self)
    end

    # key of parameter for subscription
    attr_accessor :key

  end
end
