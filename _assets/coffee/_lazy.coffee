window.Lazy = ((global, document, undefined_) ->

    "use strict"

    store = []

    tolerance = 0
    throttle = 0
    selector = "data-src"

    # Is element scrolled into view
    _inView = (elem) ->
        coords = elem.getBoundingClientRect()
        top = coords.top
        left = coords.left

        console.log top, left, (window.innerHeight or document.documentElement.clientHeight) + tolerance

        top >= 0 and left >= 0 and top <= (window.innerHeight or document.documentElement.clientHeight) + tolerance

    # Loop trough images and switch src or remove event listeners
    # if there's no more images
    _load = () ->
        if store.length > 0
            for elem in store
                if elem? and _inView elem
                    elem.src = elem.getAttribute selector
                    store.splice store.indexOf elem, 1
        else
            if document.removeEventListener then global.removeEventListener "scroll", _throttle
            else detachEvent "onscroll", _throttle
            clearTimeout poller

        console.log store

        poller = setTimeout () ->
            poller = null
        , throttle

    _throttle = () ->
        if not poller?
            _load()
        else
            clearTimeout finalPoller
            finalePoller = setTimeout _load, throttle

    init = (options) ->
        if options?
            tolerance = parseInt options.tolerance or 0
            throttle = parseInt options.throttle or 0
            selector = options.selector or "data-src"

        elements = document.querySelectorAll "img[#{selector}]"

        for elem in elements
            store.push elem

        _load()

        if document.addEventListener
            global.addEventListener "scroll", _throttle, false
            global.addEventListener "load", _throttle, false
        else
            global.attachEvent "onscroll", _throttle
            global.attachEvent "onload", _throttle

    return init: init


) this, document
