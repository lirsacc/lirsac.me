"use strict"

Helpers = {}

# Class manipulation
# --------------------------------------------------------------------------
Helpers.hasClass = (elem, className) ->
    if elem.classList
        elem.classList.contains className
    else
        new RegExp('(^| )' + className + '( |$)', 'gi').test elem.className

Helpers.toggleClass = (elem, className) ->
    if elem.classList
        elem.classList.toggle(className)
    else
        classes = elem.className.split ' '
        existingIndex = classes.indexOf(className)

        if existingIndex >= 0
            classes.splice existingIndex, 1
        else
            classes.push className

        elem.className = classes.join ' '

Helpers.addClass = (elem, className) ->
    if elem.classList
        elem.classList.add className
    else
        elem.className += ' ' + className

Helpers.removeClass = (elem, className) ->
    if Helpers.hasClass elem, className
        if elem.classList
            elem.classList.remove className
        else
            elem.className = elem.className.replace(
                new RegExp(
                    '(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'
                ), ' ')

# Objects manipulations
# --------------------------------------------------------------------------
extend = (isDeep, out) ->
    out = out or {}
    i = 2

    while i < arguments.length
        _current = arguments[i]
        continue unless _current
        for key of _current
            if _current.hasOwnProperty key
                if isDeep and typeof _current[key] is "object"
                    extend true, out[key], _current[key]
                else
                    out[key] = _current[key]
        i++
    out

Helpers.extend = extend

# Events handling
# --------------------------------------------------------------------------
Helpers.addEvent = (element, eventName, callback, useCapture) ->
    if element.addEventListener
        element.addEventListener eventName, callback, useCapture or false
    else if element.attachEvent
        element.attachEvent "on#{eventName}", callback
    else
        element["on#{eventName}"] = callback

Helpers.removeEvent = (element, eventName, callback) ->
    if element.removeEventListener
        element.removeEventListener "#{eventName}", callback
    else if element.detachEvent
        element.detachEvent "on#{eventName}", callback
    else
        element["on#{eventName}"] = undefined

Helpers.preventDefault = (event) ->
    if event.preventDefault
        event.preventDefault()
    else
        event.returnValue = false

# Functions manipulations
# --------------------------------------------------------------------------
Helpers.debounce = (func, delay) ->
    _timeout = null
    () ->
        [context, args] = [this, arguments]
        delayed = () ->
            _timeout = null
            func.apply context, args
        toCall = !_timeout
        clearTimeout _timeout
        _timeout = setTimeout delayed, delay
        if toCall then func.apply context, args

module.exports = Helpers
