
{Canvas} = require './canvas'
{Animation} = require './animation'

class AnimatedCanvas extends Canvas

  @mixin Animation

  step: (time) =>
    @draw()

module.exports = {AnimatedCanvas}
