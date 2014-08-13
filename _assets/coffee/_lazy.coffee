# Coffeescript/Vanilla JS image lazy loader
# Started as an adaptation of https://github.com/toddmotto/echo
# All credits go to respective authors
#
# Parameters :
#     *    selector (default data-src)
#     *    tolerance (default 200)
#     *    retina (default true)
#     *    throttle (default 150)

Lazy = ((global, document, undefined_) ->
    "use strict"

    # Defaults
    _tolerance = 200
    _retina = true
    _throttle = 150
    _selector = 'data-src'
    _debug = false
    _cb = ->

    _poller = null

    _inView = (elem) ->

        width = global.innerWidth or document.documentElement.clientWidth
        height = global.innerHeight or document.documentElement.clientHeight

        bounds = elem.getBoundingClientRect()

        (
            bounds.top >= 0 and
            bounds.left >= 0 and
            bounds.top <= height + _tolerance and
            bounds.left <= width + _tolerance and
            bounds.right >= - _tolerance and
            bounds.bottom >= - _tolerance
        )

    # Preload and reveal individual images when file has been downloaded
    _show = (elem) ->
        tmpImage = new Image()
        if _retina then newSrc = elem.getAttribute "#{_selector}-retina"
        # Always fall back to normal selector
        # in case retina attribute is not found
        if !newSrc then newSrc = elem.getAttribute _selector
        tmpImage.src = newSrc

        tmpImage.onload = () ->
            elem.src = tmpImage.src
            addClass elem, "loaded"
            spinner = elem.parentNode.querySelector ".spinner"
            if spinner? then elem.parentNode.removeChild spinner
            elem.removeAttribute _selector

    # Loop trough images and switch src while removing _selector attribute
    # if there's no more images, remove document level event listeners
    load = () ->

        targets = document.querySelectorAll "img[#{_selector}]"

        for target in targets when target? and _inView target
            _show target
            if _debug
                console.log "Loaded => #{target.getAttribute _selector}"
            _cb target

        if targets.length is 0
            cancel()

    cancel = () ->
        removeEvent document, "scroll", _delay
        clearTimeout _poller

    _delay = () ->
        if !!_poller
            return
        clearTimeout _poller
        _poller = setTimeout () ->
            load()
            _poller = null
        , _throttle

    init = (opts) ->

        # Parse options
        opts = opts or {}
        _tolerance = parseInt opts.tolerance or _tolerance
        _throttle = parseInt opts.throttle or _throttle
        _selector = opts.selector or _selector
        _retina = (opts.retina or _retina) and window.devicePixelRatio > 1
        _debug = opts.debug or _debug
        _cb = opts.callback or _cb

        # Add spinner
        targets = document.querySelectorAll "img[#{_selector}]"
        for elem in targets
            do (elem) ->
                spinner = document.createElement "div"
                addClass spinner, "spinner"
                elem.parentNode.appendChild spinner

        # Load first images
        load()

        # Add scroll event
        addEvent document, "scroll", _delay
        addEvent document, "load", _delay

    {
        init: init,
        load: load,
        cancel: cancel,
    }

) this, document
