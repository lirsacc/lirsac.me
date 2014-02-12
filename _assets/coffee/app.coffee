"use strict"

initScripts = () ->
    if window.Lazy? then Lazy.init tolerance: 200, throttle: 150

document.addEventListener 'DOMContentLoaded', initScripts
