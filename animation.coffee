require './animationframe'
{Base} = require './base'

class Animation extends Base
  cls = this

  cls.debug = false

  start: (element) ->
    return if @running

    @running = true
    lastFrame = window.requestAnimationFrame.now()

    step = (time) =>
      return if not @running

      delta = time - lastFrame
      lastFrame = time

      @step time, delta
      window.requestAnimationFrame step, element

      return

    if cls.debug
      numFrames = 0
      lastSample = lastFrame

      _step = step
      step = (time) ->
        _step time

        numFrames++

        if time - lastSample > 500
          fps = 1000 / ((time - lastSample) / numFrames)

          console.log "fps: #{ fps.toFixed(1) } frames: #{ numFrames } method: #{ window.requestAnimationFrame.method }"

          numFrames = 0
          lastSample = time

        return

    window.requestAnimationFrame step, element

  stop: ->
    @running = false
    return

  step: (time, delta) ->
    # animation loop

module.exports = {Animation}
