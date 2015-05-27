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

encode = (str) ->
  encodeURIComponent(str)

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


#Ajax&JSONP
jsonp = do ->
  counter = 0
  window = this
  config = {}

  load = (url, pfnError) ->
    script = document.createElement('script')
    done = false
    script.src = url
    script.async = true

    errorHandler = pfnError or config.error
    if typeof errorHandler is 'function'
      script.onerror = (ex)->
        errorHandler(
          url: url
          event: ex
        )
    script.onload = script.onreadystatechange = ->
      if (!done and (!this.readyState or this.readyState is "loaded" or this.readyState is "complete"))
        done = true
        script.onload = script.onreadystatechange = null
        if  script and script.parentNode
          script.parentNode.removeChild(script)

    if !head
      head = document.getElementsByTagName('head')[0]
    head.appendChild(script)

  jsonp = (url, params, callback, callbackName) ->
    query = if  (url or '').indexOf('?') is -1 then '?' else '&'
    callbackName = (callbackName || config['callbackName'] || 'callback')
    uniqueName = callbackName + "_" + (++counter)
    params = params || {}
    for key of params
      if params.hasOwnProperty(key)
        query += encode(key) + "=" + encode(params[key]) + "&"

    window[uniqueName] = (data)->
      callback(data)
      try
        delete window[uniqueName];
      catch e
      window[uniqueName] = null;

    load(url + query + callbackName + '=' + uniqueName)
    uniqueName

  setDefaults = (obj) ->
    config = obj

  {
  get: jsonp,
  init: setDefaults
  }

$.ajaxSettings =
  type: 'GET'
  success: ->
  error: ->
  xhr: ->
    new window.XMLHttpRequest()
  headers: {}
  accepts:
    json: 'application/json'
    html: 'text/html'
    text: 'text/plain'
  timeout: 0

ajax = (settings, success, error)->
  abortTimeout = null
  dataType = settings.dataType
  appendQuery = (url, params) ->
    query = if  (url or '').indexOf('?') is -1 then '?' else '&'
    if (params is '') then return url
    for key of params
      if params.hasOwnProperty(key)
        query += encode(key) + "=" + encode(params[key]) + "&"
    (url + query).replace(/[&?]{1,2}/, '?').slice(0, this.length - 1)
  for key of $.ajaxSettings
    if (settings[key] is undefined) then settings[key] = $.ajaxSettings[key]
  xhr = settings.xhr()

  if settings['type'].toUpperCase() is 'GET'
    settings.url = appendQuery(settings.url, settings.data)
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      xhr.onreadystatechange = ->
      clearTimeout(abortTimeout)
      result
      rsError = false
      if (xhr.status >= 200 and xhr.status < 300) or xhr.status is 304 or (xhr.status is 0 and location.protocol is 'file:')
        dataType = dataType or xhr.getResponseHeader('content-type')
        result = xhr.responseText
        try
          if dataType is 'application/json'
            result = if /^\s*$/.test(result) then null else JSON.parse(result)
        catch e
          rsError = e
        if rsError
          error(rsError, xhr.status, xhr)
        else
          success(result, xhr.status, xhr)
      else
        error(xhr.statusText || null, xhr.status, xhr)

  xhr.open(settings.type, settings.url, true)
  for k,v of settings.headers
    xhr.setRequestHeader(k, v)
  if settings.timeout > 0
    abortTimeout = setTimeout(->
      xhr.onreadystatechange = ->
      xhr.abort()
    , settings.timeout)
  xhr.send(if settings.data then settings.data else null)
  xhr
$.ajax = ajax

$.jsonp = jsonp

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

