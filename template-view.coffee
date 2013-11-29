Mustache = require 'mustache'
{View} = require './view'
{Element} = require './element'

class TemplateView extends View

  constructor: (element) ->
    super element
    @_template = Mustache.compile @template

  render: ->
    tmp = new Element 'div'
    tmp.set 'html', @_template(this)
    return tmp.query '*'

  buildElement: -> @render()


module.exports = {TemplateView}
