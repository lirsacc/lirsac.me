# Coffeescript/Vanilla JS image lazy loader
# Adapted from https://github.com/toddmotto/echo
# All credits go to respective author
#
# Parameters :
#     *    selector (default data-src)
#     *    tolerance (default 200)
#     *    handleRetina (default true)
#     *    throttle (default 150)

Lazy = ((global, document, undefined_) ->
    "use strict"

    store = []

    tolerance = 0
    throttle = 0
    selector = "data-src"

    poller = null
    globalPoller = null

    _inView = (elem) ->

        width = window.innerWidth or document.documentElement.clientWidth
        height = window.innerHeight or document.documentElement.clientHeight

        # Always true when at bottom of page
        if window.pageYOffset + height >= document.body.offsetHeight
            return true

        bounds = elem.getBoundingClientRect()
        top = bounds.top
        left = bounds.left

        top >= 0 and left >= 0 and top <= height + tolerance and left <= width

    # Preload and reveal individual images when file has been downloaded
    _show = (elem) ->
        tmpImage = new Image()
        tmpImage.src = elem.getAttribute selector

        tmpImage.onload = () ->
            store.splice store.indexOf(elem), 1
            elem.src = tmpImage.src
            addClass elem, "loaded"
            spinner = elem.parentNode.querySelector ".spinner"
            if spinner? then elem.parentNode.removeChild spinner

    # Loop trough images and switch src
    # if there's no more images, remove document level event listeners
    _load = () ->

        if store.length > 0
            for elem in store when elem? and _inView elem
                _show elem
        else
            removeEvent document, "scroll", _throttle
            clearTimeout poller

        # Sets a poller timeout which unsets itself after throttle ms
        # poller != null means _load has been executed less than throttle ms ago
        poller = setTimeout () ->
            poller = null
        , throttle

    # If poller is null => execute _load
    # else creates a globalPoller timeout which executes _load after
    # throttle ms and gets overriden when _throttle is called
    _throttle = () ->
        if not poller? then _load()
        else
            clearTimeout globalPoller
            globalPoller = setTimeout _load, throttle

    init = (options) ->

        options ?= {}
        tolerance = parseInt options.tolerance or 200
        throttle = parseInt options.throttle or 150
        selector = options.selector or "data-src"
        handleRetina = options.handleRetina or false

        if handleRetina and  window.devicePixelRatio > 1
            selector = "#{selector}-retina"

        targets = document.querySelectorAll "img[#{selector}]"

        for elem in targets
            do (elem) ->
                store.push elem
                spinner = document.createElement "div"
                addClass spinner, "spinner"
                elem.parentNode.appendChild spinner

        _load()

        addEvent document, "scroll", _throttle
        addEvent document, "load", _throttle

    return init

) this, document
