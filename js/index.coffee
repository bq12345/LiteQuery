_ = {}

$ = this.$ = (selector) ->
  selector = selector.trim()
  _.Z($.query(selector))


_.Z = (dom) ->
  new Z(dom)

Z = (dom) ->
  len = if dom then dom.length else 0
  for i of dom
    this[i] = dom[i]
  this.length = len
  this

$.ready = (callback)->
  if (/complete|loaded|interactive/.test(document.readyState) && document.body)
    callback($)
  else
    document.addEventListener('DOMContentLoaded', ->
      callback($)
    , false)
  this

$.isArraylike = (obj)->
  typeof obj.length is 'number'

$.query = (selector) ->
  slice = Array.prototype.slice
  simpleSelectorRE = /^[\w-]*$/
  result = null
  found = []
  maybeID = selector[0] == '#'
  maybeClass = !maybeID && selector[0] == '.'
  nameOnly = if  (maybeID || maybeClass) then selector.slice(1) else selector
  isSimple = simpleSelectorRE.test(nameOnly)
  if document.getElementById and isSimple and maybeID
    if found = document.getElementById(nameOnly) then result = [found] else []
  else
    if isSimple and !maybeID and document.getElementsByClassName
      if maybeClass then result = document.getElementsByClassName(nameOnly) else result = document.getElementsByTagName(selector)
    else
      result = document.querySelectorAll(selector)
    result = slice.call(result)


$.fn =
  constructor: _.Z,
  author: 'bq'
  length: 0,
  forEach: [].forEach,
  reduce: [].reduce,
  push: [].push,
  sort: [].sort,
  splice: [].splice,
  indexOf: [].indexOf

_.Z.prototype = Z.prototype = $.fn

$._ = _

