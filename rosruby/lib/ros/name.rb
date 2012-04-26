# ros/name.rb
#
# License: BSD
#
# Copyright (C) 2012  Takashi Ogura <t.ogura@gmail.com>
#
# == Naming module
#
# ROS naming module.
#

require 'socket' # for gethostname

module ROS

  ##
  # this module provides naming functions.
  #
  module Name

    # name sparation char ('/')
    SEP = '/'

    ##
    # start with '/' and use single '/' for names
    #
    # @param [String] name input name
    # @return [String] canonicalized name
    def canonicalize_name(name)
      if name == nil or name == SEP
        return name
      elsif name[0] == SEP[0]
        return name.split(/\/+/).join(SEP)
      else
        return SEP + name.split(/\/+/).join(SEP)
      end
    end

    ##
    # expand ~local_param like names.
    #
    # @param [String] caller_id caller id for replacing ~
    # @param [String] name param name like '~param'
    # @return [String] expanded name
    def expand_local_name(caller_id, name)
      if name[0] == '~'[0]
        caller_id + SEP + name[1..-1]
      else
        name
      end
    end

    ##
    # generate anonymous name using input id.
    # (arange from roslib)
    # @param [String] id base id (String)
    # @return [String] return generated id
    def anonymous_name(id)
      name = "#{id}_#{Socket.gethostname}_#{Process.pid}_#{rand(1000000)}"
      name = name.gsub('.', '_')
      name = name.gsub('-', '_')
      name.gsub(':', '_')
    end


    ##
    # expand local, canonicalize, remappings
    # @param [String] caller_id caller_id
    # @param [String] ns namespace
    # @param [String] name target name
    # @param [Array] remappings name remappings
    # @return [String] resolved name
    def resolve_name_with_call_id(caller_id, ns, name, remappings)
      name = canonicalize_name(expand_local_name(caller_id, name))
      if remappings
        remappings.each_pair do |key, value|
          if name == canonicalize_name(key)
            name = value
          end
        end
      end
      if ns
        name = ns + SEP + name
      end
      return canonicalize_name(name)
    end
  end
end
