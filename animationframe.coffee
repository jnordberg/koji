
method = 'native'
now = Date.now or -> new Date().getTime()

requestAnimationFrame = window.requestAnimationFrame
for vendor in ['webkit', 'moz', 'o', 'ms'] when not requestAnimationFrame?
  requestAnimationFrame = window["#{ vendor }RequestAnimationFrame"]

if not requestAnimationFrame?
  # polyfill using shared timer
  method = 'timer'
  lastFrame = 0
  queue = timer = null
  requestAnimationFrame = (callback) ->
    if queue?
      queue.push callback
      return

    time = now()
    nextFrame = Math.max 0, 16.66 - (time - lastFrame)

    queue = [callback]
    lastFrame = time + nextFrame

    fire = ->
      q = queue
      queue = null
      cb(lastFrame) for cb in q
      return

    timer = setTimeout fire, nextFrame
    return

# check what timestamp format is being used
# http://lists.w3.org/Archives/Public/public-web-perf/2012May/0053.html
requestAnimationFrame (time) ->
  if time < 1e12
    if window.performance?.now?
      requestAnimationFrame.now = -> window.performance.now()
      requestAnimationFrame.method = 'native-highres'
    else
      # iOS7+ and Safari6+ sends highres timestamps but
      # does not expose a way to access them
      _raf = requestAnimationFrame
      requestAnimationFrame = (callback) -> _raf -> callback now()
      requestAnimationFrame.now = now
      requestAnimationFrame.method = 'native-noperf'
      window.requestAnimationFrame = requestAnimationFrame
  else
    requestAnimationFrame.now = now
  return

# there's no way to synchronously detect high-res timestamps :-(
# naively assume highres until detection finishes if performance.now is present
requestAnimationFrame.now = if window.performance?.now? then (-> window.performance.now()) else now
requestAnimationFrame.method = method
window.requestAnimationFrame = requestAnimationFrame
