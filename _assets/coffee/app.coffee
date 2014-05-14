"use strict"

initScripts = () ->
    document.body.className = removeClass document.body, "preload"
    if Lazy? then Lazy()
    if Zoom? then Zoom()

document.addEventListener 'DOMContentLoaded', initScripts
