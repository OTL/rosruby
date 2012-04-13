module ROS

  module Name

    SEP = '/'

    def canonicalize_name(name)
      if name == nil or name == SEP
        return name
      elsif name[0] == SEP[0]
        return name.split(/\/+/).join(SEP)
      else
        return SEP + name.split(/\/+/).join(SEP)
      end
    end

    def set_remappings(remappings)
      @remappings = remappings
    end

    def expand_local_name(caller_id, name)
      if name[0] == '~'[0]
        caller_id + SEP + name[1..-1]
      else
        name
      end
    end

    def resolve_name_with_call_id(caller_id, ns, name)
      name = canonicalize_name(expand_local_name(caller_id, name))
      if @remappings
        @remappings.each_pair do |key, value|
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


