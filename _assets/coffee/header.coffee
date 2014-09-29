"use strict"

MODULE_CLASS = "Main-menu"
ACTIVE_CLASS = "is-active"

_$ = require './helpers.coffee'

_header = () ->
    document.getElementsByClassName(MODULE_CLASS)[0]

_trigger = () ->
    document.getElementsByClassName("#{MODULE_CLASS}__trigger")[0]

_handleClick = (event) ->
    _$.preventDefault event
    for child in _header().children
        _$.toggleClass child, ACTIVE_CLASS

module.exports = () ->
    _$.addEvent _trigger(), 'click', _handleClick, true
