"use strict"

_$ = require('./helpers.coffee')

_$.addEvent document, 'DOMContentLoaded', () ->

    _$.removeClass document.body, "preload"

    (require './lazy.coffee').init()
    (require './header.coffee')()
    (require './zoom.coffee')()

    null
