# ros/tcpros/message.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#

require 'ros/ros'

module ROS::TCPROS

  ##
  # header of rorpc's protocol
  #
  class Header

    # rosrpc uses this wild card for cancel md5sum check or any.
    WILD_CARD = '*'

    # initialize with hash
    # @param [Hash] data
    def initialize(data={})
      @data = data
    end

    # add key-value data to this header.
    # @param [String] key key for header
    # @param [String] value value for key
    # @return [Header] self
    def push_data(key, value)
      if (not key.kind_of?(String)) or (not value.kind_of?(String))
        raise ArgumentError::new('header key and value must be string')
      end
      @data[key] = value
      self
    end

    # @param [String] key
    # @return [String] value of key
    def get_data(key)
      @data[key]
    end

    alias_method :[]=, :push_data
    alias_method :[], :get_data

    # deserialize the data to header.
    # this does not contain total byte number.
    # @param [String] data
    # @return [Header] self
    def deserialize(data)
      while data.length > 0
        len, data = data.unpack('Va*')
        msg = data[0..(len-1)]
        equal_position = msg.index('=')
        key = msg[0..(equal_position-1)]
        value = msg[(equal_position+1)..-1]
        @data[key] = value
        data = data[(len)..-1]
      end
      self
    end

    ##
    # validate the key with the value.
    # if it is WILD_CARD, it is ok!
    # @param [String] key
    # @param [String] value
    # @return [Boolean] check result
    def valid?(key, value)
      (@data[key] == value) or value == WILD_CARD
    end

    # serialize the data into header.
    # return the byte of the serialized data.
    # @param [IO] buff where to write data
    # @return [Integer] byte of serialized data
    def serialize(buff)
      serialized_data = ''
      @data.each_pair do |key, value|
        data_str = key + '=' + value
        serialized_data = serialized_data + [data_str.length, data_str].pack('Va*')
      end
      total_byte = serialized_data.length
      return buff.write([total_byte, serialized_data].pack('Va*'))
    end

  end
end
