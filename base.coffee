
class Base

  @mixin: (classes...) ->
    for klass in classes
      for own name, method of klass
        continue if name is '__super__'
        this[name] = method
      for own name, method of klass.prototype
        continue if name is 'constructor'
        this.prototype[name] = method
      for name in Object.getOwnPropertyNames klass.prototype
        if not this.prototype[name]?
          descriptor = Object.getOwnPropertyDescriptor klass.prototype, name
          Object.defineProperty this.prototype, name, descriptor
    return

  @property: (name, descriptor) ->
    if typeof descriptor.get is 'string'
      getterName = descriptor.get
      descriptor.get = ->
        this[getterName].call(this)
    if typeof descriptor.set is 'string'
      setterName = descriptor.set
      descriptor.set = ->
        this[setterName].apply(this, arguments)
    Object.defineProperty this.prototype, name, descriptor


module.exports = {Base}
