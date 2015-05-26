Lite = {}

$ = this.$ = (selector) ->
  selector = selector.trim()
  Lite.C($.query(selector))

Lite.C = (dom) ->
  new C(dom)

C = (dom) ->
  len = if dom then dom.length else 0
  for i of dom
    this[i] = dom[i]
  this.length = len
  this

###
  一些内部使用的方法及变量
###
class2type = {}
cssNumber = {'column-count': 1, 'columns': 1, 'font-weight': 1, 'line-height': 1, 'opacity': 1, 'z-index': 1, 'zoom': 1}
isArray = Array.isArray


"Boolean Number String Function Array Date RegExp Object Error".split(" ").forEach((name)->
  class2type["[object " + name + "]"] = name.toLowerCase()
)
camelize = (str)->
  str.replace(/-+(.)?/g, (match, chr)->
# change border-color -> borderColor
    if chr then chr.toUpperCase() else ''
  )
dasherize = (str) ->
  str.replace(/::/g, '/')
  .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
  .replace(/([a-z\d])([A-Z])/g, '$1_$2')
  .replace(/_/g, '-')
  .toLowerCase()
type = (obj)  ->
  if obj == null then String(obj) else class2type[{}.toString.call(obj)] or "object"

maybeAddPx = (name, value) ->
  if (typeof value == "number" and !cssNumber[dasherize(name)]) then value + "px" else value


$.ready = (callback)->
  if (/complete|loaded|interactive/.test(document.readyState) && document.body)
    callback($)
  else
    document.addEventListener('DOMContentLoaded', ->
      callback($)
    , false)
  this
$.each = (elements, callback)->
  if ($.isArraylike(elements))
    for i in [0...elements.length]
      if (callback.call(elements[i], elements[i], i) is false) then return elements
  else
    for key in elements
      if (callback.call(elements[key], elements[key], key) is false) then return elements
  elements

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
  author: 'bq'
  length: 0,
  forEach: [].forEach,
  reduce: [].reduce,
  push: [].push,
  sort: [].sort,
  splice: [].splice,
  indexOf: [].indexOf,
  each: (callback)->
    [].every.call(this, (el, idx)->
      callback.call(el, el, idx) isnt false
    )
    this
  addClass: (name)->
    if (!name) then return this
    this.each((el, index)->
      el.classList.add(name)
    )
  removeClass: (name)->
    if (!name) then return this
    this.each((el, index)->
      el.classList.remove(name)
    )
  hasClass: (name)->
    if (!name) then return this
    this.each((el, index)->
      el.classList.contains(name)
    )
  toggleClass: (name)->
    if (!name) then return this
    this.each((el, index)->
      if el.classList.contains(name) then el.classList.remove(name) else el.classList.add(name)
    )
  css: (property, value)->
    if arguments.length < 2
      element = this[0]
      if !element then return
      computedStyle = getComputedStyle(element, '')
      if typeof property is 'string'
        return element.style[camelize(property)] || computedStyle.getPropertyValue(property)
      else
        if isArray(property)
          props = {}
          $.each(property, (prop)->
            props[prop] = (element.style[camelize(prop)] || computedStyle.getPropertyValue(prop))
          )
          props
    css = ''
    if type(property) is 'string'
      if !value and value isnt 0
        this.each(->
          this.style.removeProperty(dasherize(property))
        )
      else
        css = dasherize(property) + ":" + maybeAddPx(property, value)
    else
      for key,value of property
        if !value and value isnt 0
          this.each(->
            this.style.removeProperty(dasherize(key))
          )
        else
          css += dasherize(key) + ':' + maybeAddPx(key, value) + ';'
    this.each(->
      this.style.cssText += ';' + css
    )


Lite.C.prototype = C.prototype = $.fn

$.Lite = Lite

