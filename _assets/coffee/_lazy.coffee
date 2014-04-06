window.Lazy = ((global, document, undefined_) ->
# Coffeescript version of https://github.com/toddmotto/echo
# All credits go to respective author

    "use strict"

    store = []

    tolerance = 0
    throttle = 0
    selector = "data-src"

    # Is element scrolled into view
    _inView = (elem) ->

        reachedBottom = window.pageYOffset + window.innerHeight >= document.body.offsetHeight
        if reachedBottom then return true

        bounds = elem.getBoundingClientRect()
        top = bounds.top
        left = bounds.left

        verticalLimit = (window.innerHeight or document.documentElement.clientHeight) + tolerance
        horizontalLimit = (window.innerHeight or document.documentElement.clientHeight)

        top >= 0 and left >= 0 and top <= verticalLimit and left <= horizontalLimit


    _loadImage = (elem) ->
        elem.src = elem.getAttribute selector
        addClass elem, "loaded"
        store.splice store.indexOf(elem), 1

    _show = (elem) ->
        elem.src = elem.getAttribute selector
        addClass(elem, "loaded")
        spinner = elem.parentNode.querySelector ".spinner"
        if spinner? then elem.parentNode.removeChild spinner

    # Loop trough images and switch src or remove event listeners
    # if there's no more images
    _load = () ->

        if store.length > 0
            for elem in store
                if elem? and _inView elem
                    _show elem
                    store.splice store.indexOf(elem), 1
        else
            removeEvent document, "scroll", _throttle
            clearTimeout poller

        poller = setTimeout () ->
            poller = null
        , throttle

    _throttle = () ->
        if not poller?
            _load()
        else
            clearTimeout mainPoller
            mainPoller = setTimeout _load, throttle

    init = (options) ->
        unless options? then options = {}
        tolerance = parseInt options.tolerance or 0
        throttle = parseInt options.throttle or 0
        selector = options.selector or "data-src"
        isRetina = window.devicePixelRatio > 1
        if isRetina then selector = "#{selector}-retina"

        elements = document.querySelectorAll "img[#{selector}]"

        for elem in elements
            store.push elem
            spinner = document.createElement "div"
            addClass spinner, "spinner"
            elem.parentNode.appendChild spinner

        _load()

        addEvent global, "scroll", _throttle
        addEvent global, "load", _throttle

    return init

) this, document
