"use strict"

initScripts = () ->
    document.body.className = document.body.className.replace "preload", ""
    if window.Lazy? then Lazy.init tolerance: 200, throttle: 150

document.addEventListener 'DOMContentLoaded', initScripts
