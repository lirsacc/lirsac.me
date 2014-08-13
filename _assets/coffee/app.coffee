"use strict"

document.addEventListener 'DOMContentLoaded', () ->
    removeClass document.body, "preload"
    if Lazy? then Lazy.init()
    if Zoom? then Zoom()
