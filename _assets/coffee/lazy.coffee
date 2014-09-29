# Coffeescript/Vanilla JS image lazy loader
# Started as a coffeescript adaptation of https://github.com/toddmotto/echo
# All credits go to respective authors
#
# Options :
#   *   selector (default data-src)
#   *   tolerance (default 200)
#   *   retina (default true)
#   *   debounceRate (default 150)
#   *   cb
#   *   debug (default false)
#
# =========================================================================

"use strict"

Lazy = {}
_$ = require './helpers.coffee'

# Default options
# will get overriden through the opts object passed to init
_opts =
    tolerance: 200
    retina: true
    debounceRate: 150
    selector: 'data-src'
    debug: false
    cb: ->

_scrollHandler = null

# Test if a given element is in the current viewport
_inView = (elem) ->

    width = window.innerWidth or document.documentElement.clientWidth
    height = window.innerHeight or document.documentElement.clientHeight

    bounds = elem.getBoundingClientRect()

    ( bounds.top >= 0 and bounds.top <= height + _opts.tolerance and
      bounds.left >= 0 and bounds.left <= width + _opts.tolerance and
      bounds.right >= - _opts.tolerance and
      bounds.bottom >= - _opts.tolerance )

# Preload and reveal individual images when file has been downloaded
_show = (elem) ->
    tmpImage = new Image()
    if _opts.retina and elem.hasAttribute "#{_opts.selector}-retina"
        newSrc = elem.getAttribute "#{_opts.selector}-retina"
    else
        # Fall back to normal selector in case retina attribute isn't set
        newSrc = elem.getAttribute _opts.selector

    # Create a new image, will download the file in the background
    tmpImage.src = newSrc

    # Once loaded, replace the target with the new one which has
    # already been downloaded
    tmpImage.onload = () ->
        elem.src = tmpImage.src
        _$.addClass elem, "loaded"
        elem.removeAttribute _opts.selector
        spinner = elem.parentNode.querySelector ".spinner"
        if spinner? then elem.parentNode.removeChild spinner

# Get all img with a _opts.selector attribute
_getTargets = () ->
    document.querySelectorAll "img[#{_opts.selector}]"

# Load and show all elements inview
# Remove selector from element and call _opts.cb(element) for each element
Lazy.load = () ->

    targets = _getTargets()

    for target in targets when target? and _inView target
        _show target
        if _opts.debug
            console.log("[Lazy] #{target.getAttribute _opts.selector}",
                        target)
        _opts.cb target

    if targets.length is 0
        Lazy.cancel()

# Remove all event handler from window
Lazy.cancel = () ->
    _$.removeEvent window, 'scroll', _scrollHandler
    _$.removeEvent window, 'resize', _scrollHandler
    _$.removeEvent window, 'orientationchange', _scrollHandler

Lazy.init = (opts) ->
    _$.extend false, _opts, opts or {}
    _opts.retina = _opts.retina and window.devicePixelRatio > 1

    # Add spinners
    for elem in _getTargets()
        do (elem) ->
            spinner = document.createElement "div"
            _$.addClass spinner, "spinner"
            elem.parentNode.appendChild spinner

    # Load first images
    Lazy.load()

    if !!_opts.debounceRate
        _scrollHandler = _$.debounce Lazy.load, _opts.debounceRate
    else
        _scrollHandler = Lazy.load

    # Add scroll/resize/orientationchange event handler to window object
    _$.addEvent window, "scroll", _scrollHandler
    _$.addEvent window, "resize", _scrollHandler
    _$.addEvent window, "orientationchange", _scrollHandler

module.exports = Lazy
