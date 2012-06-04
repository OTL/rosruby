# Interpolating Quaternions
# moriq

# MIT License
#  (c) 2001 Kazuhiro Yoshida
# http://www.moriq.com/ruby/quaternion.rb

require 'matrix'

# provisional quaternion class and associated operators.  These will
# be replaced when the common quaternion library is available

class Quaternion
  attr_accessor :x, :y, :z, :w

  X = 0
  Y = 1
  Z = 2
  W = 3

  def initialize(x=0.0, y=0.0, z=0.0, w=1.0)
    @x = x
    @y = y
    @z = z
    @w = w
  end

  def to_a
    return @x, @y, @z, @w
  end

  def inspect
    type.inspect + to_a.inspect
  end

  def [](i)
    case i
    when X; @x
    when Y; @y
    when Z; @z
    when W; @w
    else nil
    end
  end

  def []=(i, v)
    case i
    when X; @x = v
    when Y; @y = v
    when Z; @z = v
    when W; @w = v
    else nil
    end
  end

  #
  # Matrix-Quaternion Conversions
  #

  # Convert a quaternion (q) to a 4x4 matrix (m)
  def to_matrix
    # If q is guaranteed to be a unit quaternion, s will always
    # be 1.  In that case, this calculation can be optimized out.

    norm = @x*@x + @y*@y + @z*@z + @w*@w
    s = if norm > 0 then 2.0/norm else 0 end

    # Precalculate coordinate products

    xx = @x*@x*s
    yy = @y*@y*s
    zz = @z*@z*s
    xy = @x*@y*s
    xz = @x*@z*s
    yz = @y*@z*s
    wx = @w*@x*s
    wy = @w*@y*s
    wz = @w*@z*s

    # Calculate 3x3 matrix from orthonormal basis

    # 4th row and column of 4x4 matrix
    # Translation and scale are not stored in quaternions, so these
    # values are set to default (no scale, no translation).
    # For systems where m comes pre-loaded with scale and translation
    # factors, this code can be excluded.

    Matrix[
      [1.0 - (yy + zz),  (xy - wz).to_f,  (wy + xz).to_f, 0.0],
      [ (xy + wz).to_f, 1.0 - (xx + zz),  (yz - wx).to_f, 0.0],
      [ (xz - wy).to_f,  (yz + wx).to_f, 1.0 - (xx + yy), 0.0],
      [            0.0,             0.0,             0.0, 1.0],
    ]
  end

  def Quaternion.from_matrix(m)
    # This code can be optimized for m[W,W] = 1, which
    # should always be true.  This optimization is excluded
    # here for clarity.
    r = m[X,X] + m[Y,Y] + m[Z,Z] + m[W,W]

    #  w >= 0.5 ?
    if r >= 1.0
      d = 2.0*Math.sqrt(r)
      Quaternion.new(
        (m[Z,Y] - m[Y,Z])/d,
        (m[X,Z] - m[Z,X])/d,
        (m[Y,X] - m[X,Y])/d,
        d/4.0)
    else
      # Find the largest component.
      if m[X,X] > m[Y,Y]
        i = X
      else
        i = Y
      end
      if m[Z,Z] > m[i,i]
        i = Z
      end

      # Set j and k to point to the next two components
      j = (i+1)%3
      k = (j+1)%3

      # d = 4 * largest component
      d = 2.0*Math.sqrt(m[i,i] - m[j,j] - m[k,k] + 1.0)

      q = Quaternion.new(0, 0, 0, 1)
      # Set the largest component
      q[i] = d/4.0
      # Calculate remaining components
      q[j] = (m[j,i] + m[i,j])/d
      q[k] = (m[k,i] + m[i,k])/d
      q[W] = (m[k,j] - m[j,k])/d
      q
    end
  end

  def length
    Math.sqrt(@x*@x + @y*@y + @z*@z + @w*@w)
  end

  def normalize
    mag = length
    if mag > 0
      @x = @x/v
      @y = @y/v
      @z = @z/v
      @w = @w/v
    end
    # self /= mag
    self
  end

  def -@
    Quaternion.new(-@x, -@y, -@z, -@w)
  end

  def +@
    Quaternion.new(+@x, +@y, +@z, +@w)
  end

  def *(v)
    case v
    when Numeric
      Quaternion.new(@x*v, @y*v, @z*v, @w*v)
    when Quaternion
      Quaternion.new(
        @y*v.z - @z*v.y + @w*v.x + @x*v.w,
        @z*v.x - @x*v.z + @w*v.y + @y*v.w,
        @x*v.y - @y*v.x + @w*v.z + @z*v.w,
        @w*v.w - @x*v.x - @y*v.y - @z*v.z)
    else
      x, y = v.coerce(self)
      return x * y
    end
  end

  def /(v)
    case v
    when Numeric
      Quaternion.new(@x/v, @y/v, @z/v, @w/v)
    else
      x, y = v.coerce(self)
      return x / y
    end
  end

  def -(v)
    case v
    when Quaternion
      Quaternion.new(
        @x-v.x,
        @y-v.y,
        @z-v.z,
        @w-v.w)
    else
      x, y = v.coerce(self)
      return x - y
    end
  end

  def +(v)
    case v
    when Quaternion
      Quaternion.new(
        @x+v.x,
        @y+v.y,
        @z+v.z,
        @w+v.w)
    else
      x, y = v.coerce(self)
      return x + y
    end
  end

  def coerce(other)
    case other
    when Numeric
      return self, other
    else
      raise TypeError, "#{type} can't be coerced into #{other.type}"
    end
  end

  def unit
    self / length
  end

  # Logarithm of a quaternion, given as:
  # Qlog(q) = v*a where q = [cos(a),v*sin(a)]
  def Quaternion.log(q)
    a = Math.acos(q.w)
    sina = Math.sin(a)
    if sina > 0
      Quaternion.new(
        a*q.x/sina,
        a*q.y/sina,
        a*q.z/sina,
        0)
    else
      Quaternion.new(0, 0, 0, 0)
    end
  end

  # e^quaternion given as:
  # Qexp(v*a) = [cos(a),v*sin(a)]
  def Quaternion.exp(q)
    a = Math.sqrt(q.x*q.x + q.y*q.y + q.z*q.z)
    sina = Math.sin(a)
    cosa = Math.cos(a)
    if a > 0
      Quaternion.new(
        sina*q.x/a,
        sina*q.y/a,
        sina*q.z/a,
        cosa)
    else
      Quaternion.new(0, 0, 0, cosa)
    end
  end

  # Linear interpolation between two quaternions
  def Quaternion.lerp(q1, q2, t)
    (q1 + t*(q2-q1)).normalize
  end

  # Spherical linear interpolation between two quaternions
  def Quaternion.slerp(q1, q2, t)
    dot = q1.x*q2.x + q1.y*q2.y + q1.z*q2.z + q1.w*q2.w

    # dot = cos(theta)
    # if (dot < 0), self and q are more than 90 degrees apart,
    # so we can invert one to reduce spinning

    if dot < 0
      dot = -dot
      q3 = -q2
    else
      q3 = +q2
    end

    if dot < 0.95
      angle = acos(dot)
      sina = sin(angle)
      sinat = sin(angle*t)
      sinaomt = sin(angle*(1-t))
      return (q1*sinaomt + q3*sinat)/sina
    else
      # if the angle is small, use linear interpolation
      return Quaternion.lerp(q1, q3, t)
    end
  end

  # dot product
  def Quaternion.dot(q1, q2)
    q1.x*q2.x + q1.y*q2.y + q1.z*q2.z + q1.w*q2.w
  end

  # This version of slerp, used by squad, does not check for theta > 90.
  def Quaternion.slerp_no_invert(q1, q2, t)
    dot = Quaternion.dot(q1, q2)

    if dot > -0.95 && dot < 0.95
      angle = Math.acos(dot)
      sina = Math.sin(angle)
      sinat = Math.sin(angle*t)
      sinaomt = Math.sin(angle*(1-t))
      return (q1*sinaomt + q2*sinat)/sina
    else
      # if the angle is small, use linear interpolation
      return Quaternion.lerp(q1, q2, t)
    end
  end

  # Spherical cubic interpolation
  def Quaternion.squad(q1, q2, qa, qb, t)
    qc = Quaternion.slerp_no_invert(q1, q2, t)
    qd = Quaternion.slerp_no_invert(qa, qb, t)
    Quaternion.slerp_no_invert(qc, qd, 2*t*(1-t))
  end

  # Given 3 quaternions, qn-1, qn and qn+1, calculate a control point
  # to be used in spline interpolation
  def Quaternion.spline(q0, q1, q2)
    qi = Quaternion.new(-q1.x, -q1.y, -q1.z, +q1.w)
    q1*Quaternion.exp((Quaternion.log(qi*q0)+Quaternion.log(qi*q2))/-4)
  end

end
