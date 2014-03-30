{EventEmitter} = require 'events'
{Animation} = require './animation'

noop = ->

class Transition extends Animation

  @mixin EventEmitter

  # easing functions ported from d3.js
  EasingFunctions =
    linear: -> (t) -> t
    quad: -> (t) -> Math.pow t, 2
    cubic: -> (t) -> Math.pow t, 3
    sin: -> (t) -> 1 - Math.cos(t * Math.PI / 2)
    exp: -> (t) -> Math.pow(2, 10 * (t - 1))
    back: (s=1.70158) -> (t) -> t * t * ((s + 1) * t - s)
    poly: (e) -> (t) -> Math.pow t, e
    elastic: (a, p=0.45) ->
      if a?
        s = p / (2 * Math.PI) * Math.asin(1 / a)
      else
        a = 1
        s = p / 4
      return (t) -> 1 + a * Math.pow(2, 10 * -t) * Math.sin((t - s) * 2 * Math.PI / p)
    bounce: ->
      (t) -> `t < 1 / 2.75 ? 7.5625 * t * t : t < 2 / 2.75 ? 7.5625 * (t -= 1.5 / 2.75) * t + .75 : t < 2.5 / 2.75
              ? 7.5625 * (t -= 2.25 / 2.75) * t + .9375 : 7.5625 * (t -= 2.625 / 2.75) * t + .984375`

  EasingHelpers =
    reverse: (f) -> (t) -> 1 - f(1 - t)
    reflect: (f) -> (t) -> 0.5 * (if t < 0.5 then f(2 * t) else 2 - f(2 - 2 * t))

  Interpolators =
    number: (from, to) ->
      (t) -> from * (1 - t) + to * t
    object: (from, to) ->
      object = {}
      keys = (key for key of from)
      (t) ->
        for key in keys
          object[key] = from[key] * (1 - t) + to[key] * t
        return object

  constructor: (options = {}) ->
    @setEasingFunction options.ease or 'cubic-in-out'
    @setInterpolator options.interpolate or 'number'
    @duration = options.duration or 1000
    @update = options.update or noop

  setInterpolator: (factory) ->
    if typeof factory is 'string'
      factory = Interpolators[factory]
      if not factory?
        throw new Error "Unknown interpolation method: #{ factory }"
    @buildInterpolator = factory

  setEasingFunction: (fn, options...) ->
    if typeof fn is 'string'
      parts = fn.split '-'
      name = parts.shift()
      type = parts.join('-') or 'in'

      factory = EasingFunctions[name]
      if not factory?
        throw new Error "Unknown easing method: #{ fn }"

      fn = factory.apply EasingFunctions, options
      switch type
        when 'in'
          fn = fn
        when 'out'
          fn = EasingHelpers.reverse fn
        when 'in-out'
          fn = EasingHelpers.reflect fn
        when 'out-in'
          fn = EasingHelpers.reflect EasingHelpers.reverse fn
        else
          throw new Error "Unknown easing type: #{ type }"

    @ease = fn

  configure: (from, to) ->
    if not to?
      to = from
      if @now?
        from = @now
      else
        throw new Error 'No previous value for now'

    @interpolate = @buildInterpolator from, to

  start: (args...) ->
    options = {}
    params = ['from', 'to', 'duration', 'delay']

    if typeof args[0] is 'object'
      options = args[0]
      options.callback = args[1] if typeof args[1] is 'function'
    else
      idx = 0
      for arg in args
        if typeof arg is 'function'
          options.callback = arg
        else
          options[params[idx++]] = arg

    @configure options.from, options.to
    @duration = options.duration if options.duration?
    @callback = options.callback

    clearTimeout @_delayTimer if @_delayTimer?

    start = =>
      @startTime = window.requestAnimationFrame.now()
      Transition.__super__.start.call this
      @emit 'start'

    if options.delay?
      @_delayTimer = setTimeout start, options.delay
    else
      start()

  stop: ->
    if @_delayTimer?
      clearTimeout @_delayTimer
      @_delayTimer = null

    @emit 'stop'
    super()

  step: (time) ->
    delta = time - @startTime

    t = delta / @duration

    if t >= 1 then t = 1

    @set t

    if t is 1
      @stop()
      if @callback?
        @callback()
        @callback = null

    return

  set: (t) ->
    @now = @interpolate @ease t
    @update @now, t
    return


module.exports = {Transition}
