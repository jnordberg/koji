
capitalize = (string) ->
  str = string.toLowerCase()
  return str[0].toUpperCase() + str.slice(1)

camelize = (words, firstChar=false) ->
  if firstChar
    words.map(capitalize).join('')
  else
    words[0].toLowerCase() + words.slice(1).map(capitalize).join('')

decamelize = (string) ->
  rv = []
  word = string[0].toLowerCase()
  for char in string.slice(1)
    lowerChar = char.toLowerCase()
    if char isnt lowerChar
      rv.push word
      word = lowerChar
    else
      word += lowerChar
  rv.push word
  return rv

underscore2camel = (string) ->
  camelize string.split('_')

hypen2camel = (string) ->
  camelize string.split('-')

camel2hypen = (string) ->
  decamelize(string).join('-')

camel2underscore = (string) ->
  decamelize(string).join('_')

hypen2underscore = (string) ->
  string.replace /-/g, '_'

underscore2hypen = (string) ->
  string.replace /_/g, '-'

module.exports = {
  capitalize
  camelize, decamelize
  underscore2camel, camel2underscore
  hypen2camel, camel2hypen
  underscore2hypen, hypen2underscore
}
