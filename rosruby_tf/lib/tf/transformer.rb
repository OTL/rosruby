#
#
#
require 'tf/quaternion'
require 'matrix'

class Matrix
  def []=(i,j,x)
    @rows[i][j]=x
  end
end

module Tf

  class Transform

    def to_matrix
      q = Quaternion.new(*@rot)
      mat = q.to_matrix
      mat[0,3] = @pos[0]
      mat[1,3] = @pos[1]
      mat[2,3] = @pos[2]
      mat
    end

    def initialize(frame_id, pos, rot, parent)
      @frame_id = frame_id
      @parent = parent
      @pos = pos
      @rot = rot
      @stamp = nil
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
      transform = Matrix::identity(4)
      if path
        for i in 0..(path.length-2)
          current_frame = path[i]
          next_frame = path[i+1]
          if current_frame.parent == next_frame
            transform *= current_frame.to_matrix.inverse
          else # this means next's parent is current
            transform *= next_frame.to_matrix
          end
        end
        transform
      else
        nil
      end
    end

    attr_accessor :pos
    attr_accessor :rot
    attr_accessor :parent
    attr_accessor :frame_id
    attr_accessor :stamp

  end

  class TransformBuffer
    def initialize
      @max_buffer_length = 100
      @transforms = {}
    end

    def find_transform(frame_id, stamp)
      if not stamp or stamp == ROS::Time.new
        # latest
        @transforms[frame_id].last
      else
        @transforms[frame_id].each do |trans|
          if stamp > trans.stamp
            return trans
          end
        end
      end
      nil
    end

    def add_transform(trans)
      if @transform[trans.frame_id]
        @transforms[trans.frame_id].push(trans)
      else
        @transform[trans.frame_id] = [trans]
        if @transform[trans.frame_id].length > @max_buffer_length
          @transform[trans.frame_id].shift
        end
      end
      # it is better to set parent again?
    end
  end

end
