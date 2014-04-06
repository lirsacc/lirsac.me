"use strict"

initScripts = () ->
    document.body.className = document.body.className.replace "preload", ""
    if window.Lazy? then Lazy tolerance: 200, throttle: 150
    if window.Zoom? then Zoom()

document.addEventListener 'DOMContentLoaded', initScripts
