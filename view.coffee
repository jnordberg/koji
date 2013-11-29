{Base} = require './base'
{Element} = require './element'

class View extends Base

  template: '<div></div>'

  constructor: (element) ->
    @element = element if element?

  @property 'element', {get: 'getElement', set: 'setElement'}

  setElement: (element) ->
    @_element = Element.ensure element
    @setupElement @_element

  getElement: ->
    if not @_element
      @setElement @buildElement()
    return @_element

  buildElement: ->
    tmp = new Element 'div'
    tmp.set 'html', @template
    return tmp.query '*'

  setupElement: (element) ->
    # subclasses should implement this to configure the element


module.exports = {View}
