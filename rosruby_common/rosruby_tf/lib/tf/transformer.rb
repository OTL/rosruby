#
#
#
module Tf

  class Transform

    def initialize(frame_id, pos, rot, parent)
      @frame_id = frame_id
      @parent = parent
      @pos = pos
      @rot = rot
    end

    def to_s
      @frame_id
    end

    def get_path(target)
      target_path = target.find_root
      self_path = self.find_root
      if target_path.last == self_path.last
        while target_path.last == self_path.last
          root = target_path.last
          target_path.pop
          self_path.pop
        end
        self_path + [root] + target_path.reverse
      else
        nil
      end
    end

    def find_root(path=[])
      if not @parent
        path.push(self)
      else
        @parent.find_root(path.push(self))
      end
    end

    def is_connected?(target)
      target_path = target.find_root
      self_path = self.find_root
      target_path.last == self_path.last
    end

    def get_transform_to(target)
      path = get_path(target)
      if path
        path.each do |trans|
        end
      else
        nil
      end
    end
  end

  class Transformer

  end

end
