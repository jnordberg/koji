{Base} = require './base'

rad2deg = (rad) ->
  rad * 57.29577951308232 # rad / Math.PI * 180

deg2rad = (deg) ->
  deg * 0.017453292519943295 # (deg / 180) * Math.PI

class Geometry extends Base

  constructor: (args...) ->
    @offset = 0 # the offset allows the data to be passed along, e.g. from a rect
    if args.length is 1
      @data = args[0]
    else if args.length > 1
      @data = args
    else
      @data = []

  clone: ->
    copy = []
    for i in [0...@data.length]
      copy[i] = @data[i]
    return new this.constructor copy

  @select: (obj) ->
    if obj instanceof this
      return obj
    else
      return new this obj

class Point extends Geometry

  @property 'x', {get: 'getX', set: 'setX'}
  getX: -> @data[@offset]
  setX: (val) -> @data[@offset] = val

  @property 'y', {get: 'getY', set: 'setY'}
  getY: -> @data[@offset + 1]
  setY: (val) -> @data[@offset + 1] = val

  @property 'length', {get: 'getLength'}
  getLength: ->
    ### Pythagorean length of point from origo. ###
    return Math.sqrt(Math.pow(@x, 2) + Math.pow(@y, 2))

  distanceTo: (point) ->
    ### Distance to *point*. ###
    xd = point.x - @x
    yd = point.y - @y
    return Math.sqrt(xd * xd + yd * yd)

  add: (point) ->
    ### Add *point* to this point. ###
    @x += point.x
    @y += point.y
    return this

  substract: (point) ->
    ### Substract *point* from this point. ###
    @x -= point.x
    @y -= point.y
    return this

  multiply: (factor) ->
    ### Multiply by *factor*. ###
    @x *= factor
    @y *= factor
    return this

  dot: (point) ->
    ### Dot product of *point* and this point. ###
    return @x * point.x + @y * point.y

  normalize: ->
    ### Normalize this point. ###
    @multiply 1 / @length
    return this

  angle: (point) ->
    ### Angle to *point* in radians. ###
    return Math.atan2(point.y - @y, point.x - @x)

class Size extends Geometry

  @property 'width', {get: 'getWidth', set: 'setWidth'}
  getWidth: -> @data[@offset]
  setWidth: (val) -> @data[@offset] = val

  @property 'height', {get: 'getHeight', set: 'setHeight'}
  getHeight: -> @data[@offset + 1]
  setHeight: (val) -> @data[@offset + 1] = val

  @property 'mid', {get: 'getMid'}
  getMid: -> new Point @width / 2, @height / 2

  standardize: ->
    @width = Math.abs @width
    @height = Math.abs @height
    return this

  aspectFit: (size, keepInside=true) ->
    ### Scales size to the size given, keeping aspect ratio. If *keepInside* is true size will be scaled to _maximum_
        the size given; otherwise it will be scaled to _at least_ the size given. ###
    size = Size.select size
    nw = size.height * @width / @height
    nh = size.width * @height / @width
    if keepInside ^ (nw >= size.width)
      @width = nw or 1
      @height = size.height
    else
      @height = nh or 1
      @width = size.width
    return this

  scale: (factor) ->
    ### Scales the size by *factor*. ###
    @width *= factor
    @height *= factor

class Rect extends Geometry

  @property 'x', {get: 'getX', set: 'setX'}
  getX: -> @data[@offset]
  setX: (val) -> @data[@offset] = val

  @property 'y', {get: 'getY', set: 'setY'}
  getY: -> @data[@offset + 1]
  setY: (val) -> @data[@offset + 1] = val

  @property 'x1', {get: 'getX1', set: 'setX1'}
  getX1: -> @data[@offset]
  setX1: (val) -> @data[@offset] = val

  @property 'y1', {get: 'getY1', set: 'setY1'}
  getY1: -> @data[@offset + 1]
  setY1: (val) -> @data[@offset + 1] = val

  @property 'x2', {get: 'getX2', set: 'setX2'}
  getX2: -> @data[@offset] + @data[@offset + 2]
  setX2: (val) -> @data[@offset + 2] = val - @data[@offset]

  @property 'y2', {get: 'getY2', set: 'setY2'}
  getY2: -> @data[@offset + 1] + @data[@offset + 3]
  setY2: (val) -> @data[@offset + 3] = val - @data[@offset + 1]

  @property 'width', {get: 'getWidth', set: 'setWidth'}
  getWidth: -> @data[@offset + 2]
  setWidth: (val) -> @data[@offset + 2] = val

  @property 'height', {get: 'getHeight', set: 'setHeight'}
  getHeight: -> @data[@offset + 3]
  setHeight: (val) -> @data[@offset + 3] = val

  @property 'size', {get: 'getSize', set: 'setSize'}
  getSize: ->
    if not @_size?
      @_size = new Size @data
      @_size.offset = 2
    return @_size
  setSize: (size) ->
    size = Size.select size
    @data[2] = size.width
    @data[3] = size.height

  @property 'origin', {get: 'getOrigin', set: 'setOrigin'}
  getOrigin: ->
    if not @_origin?
      @_origin = new Point @data
    return @_origin
  setOrigin: (point) ->
    point = Point.select point
    @data[0] = point.x
    @data[1] = point.y

  @property 'mid', {get: 'getMid', set: 'setMid'}
  getMid: -> new Point @x + (@width / 2), @y + (@height / 2)
  setMid: (mid) ->
    mid = Point.select mid
    @origin = new Point mid.x - (@width / 2), mid.y - (@height / 2)

  standardize: ->
    ### Ensure that rectangle has a positive width and height. ###
    if @x > @x + @width
      @x = @x + @width
      @width = Math.abs @width
    if @y > @y + @height
      @y = @y + @height
      @height = Math.abs @height
    return this

  inset: (delta) ->
    ### Shrinks or expands rectangle by *delta* keeping the same center point. ###
    delta = Point.select delta
    @origin.addPoint delta
    @size.width -= delta.x * 2
    @size.height -= delta.y * 2
    return this

  containsPoint: (point) ->
    ### Check if this rectangle contains the specified *point*. ###
    point = Point.select point
    return (
      @origin.x <= point.x and @origin.y <= point.y and
      @origin.x + @size.width >= point.x and
      @origin.y + @size.height >= point.y
    )

  containsRect: (rect) ->
    ### Check if this rectangle fully contains the specified *rect*. ###
    rect = Rect.select rect
    return (@containsPoint(rect.origin) and @containsPoint([rect.x2, rect.y2]))

  intersectsRect: (rect) ->
    ### Check if this rectangle intersects *rect*. ###
    rect = Rect.select rect
    return !(@x1 > rect.x2 or @x2 < rect.x1 or
             @y1 > rect.y2 or @y2 < rect.y1)


module.exports = {Point, Size, Rect, deg2rad, rad2deg}
