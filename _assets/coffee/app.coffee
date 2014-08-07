"use strict"

init = () ->
    removeClass document.body, "preload"
    if Lazy? then Lazy()
    if Zoom? then Zoom()

document.addEventListener 'DOMContentLoaded', init
