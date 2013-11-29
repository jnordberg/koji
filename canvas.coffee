{Element} = require './element'
{View} = require './view'
{Size} = require './geometry'

class Canvas extends View

  constructor: (args...) ->
    @size = Object.create Size.prototype
    Size.apply @size, arguments

  setSize: (size) ->
    @size = Size.select size
    @element.set
      width: @size.width
      height: @size.height
    @draw()

  buildElement: ->
    new Element 'canvas'

  setupElement: (element) ->
    element.set
      width: @size.width
      height: @size.height
    @draw()

  getContext: (type='2d') ->
    @getElement().node.getContext type

  draw: ->
    # subclasses should implement this


module.exports = {Canvas}
