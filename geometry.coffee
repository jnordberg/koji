{Base} = require './base'

rad2deg = (rad) ->
  rad * 57.29577951308232 # rad / Math.PI * 180

deg2rad = (deg) ->
  deg * 0.017453292519943295 # (deg / 180) * Math.PI

class Geometry extends Base

  constructor: (args...) ->
    if args.length is 1
      if args[0] instanceof Array
        @data = args[0]
      else
        @data = []
        for key, val of args[0]
          this[key] = val
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
  getX: -> @data[0]
  setX: (val) -> @data[0] = val

  @property 'y', {get: 'getY', set: 'setY'}
  getY: -> @data[1]
  setY: (val) -> @data[1] = val

  @property 'length', {get: 'getLength'}
  getLength: ->
    ### Pythagorean length of point from origo. ###
    return Math.sqrt(Math.pow(@x, 2) + Math.pow(@y, 2))

  distanceTo: (point) ->
    ### Distance to *point*. ###
    point = Point.select point
    xd = point.x - @x
    yd = point.y - @y
    return Math.sqrt(xd * xd + yd * yd)

  add: (point) ->
    ### Add *point* to this point. ###
    point = Point.select point
    @x += point.x
    @y += point.y
    return this

  substract: (point) ->
    ### Substract *point* from this point. ###
    point = Point.select point
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
    point = Point.select point
    return @x * point.x + @y * point.y

  normalize: ->
    ### Normalize this point. ###
    @multiply 1 / @length
    return this

  angle: (point) ->
    ### Angle to *point* in radians. ###
    point = Point.select point
    return Math.atan2(point.y - @y, point.x - @x)

class Size extends Geometry

  @property 'width', {get: 'getWidth', set: 'setWidth'}
  getWidth: -> @data[0]
  setWidth: (val) -> @data[0] = val

  @property 'height', {get: 'getHeight', set: 'setHeight'}
  getHeight: -> @data[1]
  setHeight: (val) -> @data[1] = val

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
    return this

class Rect extends Geometry

  constructor: (args...) ->
    switch args.length
      when 4
        @origin = new Point args[0], args[1]
        @size = new Size args[2], args[3]
      when 2
        @origin = Point.select args[0]
        @size = Size.select args[1]
      else
        @origin = new Point args[0][0], args[0][1]
        @size = new Size args[0][2], args[0][3]

  clone: ->
    new Rect @origin.clone(), @size.clone()

  @property 'x', {get: 'getX', set: 'setX'}
  getX: -> @origin.x
  setX: (val) -> @origin.x = val

  @property 'y', {get: 'getY', set: 'setY'}
  getY: -> @origin.y
  setY: (val) -> @origin.y = val

  @property 'x1', {get: 'getX1', set: 'setX1'}
  getX1: -> @origin.x
  setX1: (val) -> @origin.x = val

  @property 'y1', {get: 'getY1', set: 'setY1'}
  getY1: -> @origin.y
  setY1: (val) -> @origin.y = val

  @property 'x2', {get: 'getX2', set: 'setX2'}
  getX2: -> @origin.x + @size.width
  setX2: (val) -> @size.width = val - @origin.x

  @property 'y2', {get: 'getY2', set: 'setY2'}
  getY2: -> @origin.y + @size.height
  setY2: (val) -> @size.height = val - @origin.y

  @property 'width', {get: 'getWidth', set: 'setWidth'}
  getWidth: -> @size.width
  setWidth: (val) -> @size.width = val

  @property 'height', {get: 'getHeight', set: 'setHeight'}
  getHeight: -> @size.height
  setHeight: (val) -> @size.height = val

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
    if typeof delta is 'number'
      delta = new Point [delta, delta]
    else
      delta = Point.select delta
    @origin.add delta
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
