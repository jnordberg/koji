bean = require 'bean'
{Point, Size, Rect} = require './geometry'
{Base} = require './base'

toArray = (thing) -> Array.prototype.slice.call(thing)

ensure = (element) ->
  if element not instanceof Element
    new Element element
  else
    element

isNumber = (n) ->
  !isNaN(parseFloat(n)) && isFinite(n)

toCamelCase = (s) ->
  s.replace /(\-[a-z])/g, (match) ->
    match.toUpperCase().replace('-', '')

setStyle = (element, style, value) ->
  if isNumber value
    value = "#{ Math.round(value) }px"
  element.style[toCamelCase(style)] = value
  return

setStyles = (element, styles) ->
  for key, value of styles
    setStyle element, key, value
  return

setProperty = (element, key, value) ->
  switch key
    when 'html'
      element.innerHTML = value
    when 'style', 'styles'
      setStyles element, value
    else
      element[key] = value
  return

class Element extends Base

  constructor: (node, properties) ->
    if typeof node is 'string'
      node = document.createElement node
    else if node instanceof Element
      node = node.node
    @node = node
    if properties?
      @set properties

  adopt: (element) ->
    @node.appendChild ensure(element).node

  insertInto: (element) ->
    ensure(element).adopt @node

  insertBefore: (element) ->
    throw new Error 'Not implemented.'

  insertAfter: (element) ->
    throw new Error 'Not implemented.'

  empty: ->
    for node in toArray @node.childNodes
      node.parentNode?.removeChild node
    return

  remove: ->
    @node.parentNode?.removeChild @node
    return

  query: (query) ->
    Element.query query, @node

  queryAll: (query) ->
    Element.queryAll query, @node

  addEvent: (args...) ->
    args.unshift @node
    bean.add.apply null, args

  removeEvent: (args...) ->
    args.unshift @node
    bean.remove.apply null, args

  fireEvent: (args...) ->
    args.unshift @node
    bean.remove.apply null, args

  set: (property, value) ->
    if typeof property is 'object'
      setProperty @node, k, v for k, v of property
    else
      setProperty @node, property, value

  setStyle: (style, value) ->
    setStyle @node, style, value

  setStyles: (styles) ->
    setStyles @node, styles

  getPosition: ->
    # TODO: fallback for bad browsers
    bounds = @node.getBoundingClientRect()
    return new Point [
      bounds.left + document.body.scrollLeft
      bounds.top + document.body.scrollTop
    ]

  setPosition: (position) ->
    @node.style.transform = "translate(#{ position.x }, #{ position.y });"

    # @setStyles
    #   'left': position.x
    #   'top': position.y

  setSize: (size) ->
    @setStyles
      width: size.width
      height: size.height

  getSize: ->
    new Size @node.offsetWidth, @node.offsetHeight

  getRect: ->
    new Rect @getPosition(), @getSize()

Element.queryAll = (query, target=document) ->
  nodes = toArray target.querySelectorAll query
  return nodes.map (node) -> new Element node

Element.query = (query, target=document) ->
  node = target.querySelector query
  if node?
    return new Element node
  return null

Element.ensure = ensure
Element.select = ensure

module.exports = {Element}
