module ROS

  module Name

    SEP = '/'

    def canonicalize_name(name)
      if name == nil or name == SEP
        return name
      elsif name[0] == SEP
        return name.split(/\/+/).join('/')
      else
        return '/' + name.split(/\/+/).join('/')
      end
    end

    def set_remappings(remapping)
      @remapping = remapping
    end

    def resolve_name_with_call_id(caller_id, name)
      if name[0] == '~'[0]
        name = caller_id + '/' + name[1..-1]
      end
      name = canonicalize_name(name)
      if @remapping and @remapping.has_key(name)
        name = @remapping[name]
      end
      return name
    end
  end
end


