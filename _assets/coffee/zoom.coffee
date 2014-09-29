# Simple vanilla js image zooming script
#
# Parameters :
#     *    selector (default data-zoom)
#     *    useEscape (default true)
#     *    classPrefix (default Zoom)
#     *    scale (default .98)
#     *    retina (default: true)
#
# TODO :
#     *    Add throttling on _resize, _activate & _set
#     *    Touch events
#     *    Preloading & loading spinner
#     *    Arrow keys to navigate + preloading
#     *    Handle data-legend / captions
#     *    Handle galleries
#
# =========================================================================

"use strict"

_$ = require './helpers.coffee'

_opts =
    scale: .98
    retina: true
    selector: 'data-zoom'
    useEscape: true
    classPrefix: 'Zoom'

_active = false

_overlay = undefined
_wrapper = undefined
_image = undefined

# Default centering for an image / object
_resetCurrentImageDimensions = () ->
    _image.setAttribute "style", "width: 0; height: 0"

_updateImageDimensions = (img, force) ->
    force = force or false

    screenWidth = ( global.innerWidth or
                    document.documentElement.clientWidth )
    screenHeight = ( global.innerHeight or
                     document.documentElement.clientHeight )

    maxWidth = _opts.scale * screenWidth
    maxHeight = _opts.scale * screenHeight

    screenRatio = screenWidth / screenHeight

    imgWidth = img.width
    imgHeight = img.height

    imgRatio = imgWidth / imgHeight

    if imgWidth > maxWidth or imgHeight > maxHeight or force
        if imgRatio > screenRatio
            imgWidth = maxWidth
            imgHeight = imgWidth / imgRatio
        else
            imgHeight = maxHeight
            imgWidth = imgRatio * imgHeight

    img.style.width = "#{imgWidth}px"
    img.style.height = "#{imgHeight}px"

_setCurrentImage = (elem) ->
    newImg = new Image()
    if _opts.retina and elem.hasAttribute "#{_opts.selector}-retina"
        newSrc = elem.getAttribute "#{_opts.selector}-retina"
    else
        newSrc = elem.getAttribute _opts.selector

    newImg.src = newSrc

    newImg.onload = () ->
        _updateImageDimensions newImg
        _image.src = newImg.src
        _image.style.width = newImg.style.width
        _image.style.height = newImg.style.height

        _activate()

_resize = () ->
    if _active and !!_image
        _updateImageDimensions _image, true

_isValidImage = (elem) ->
    elem.tagName == "IMG"

_insertMarkup = (cls) ->
    el = document.createElement "div"
    _$.addClass el, "#{cls}__wrapper"
    el.innerHTML = "<div class='#{cls}__overlay'></div>\
                   <img src='' class='#{cls}__image'/>"
    (document.body or document.documentElement).appendChild el

_activate = () ->
    unless not !!_image or _active
        _active = true
        _$.addClass _wrapper, "is-active"

_deactivate = () ->
    if _active
        _active = false
        _$.removeClass _wrapper, "is-active"
        _resetCurrentImageDimensions()

module.exports = (opts) ->

    _opts = _$.extend false, _opts, opts or {}
    _opts.retina = _opts.retina and window.devicePixelRatio > 1

    targets = document.querySelectorAll "img[#{_opts.selector}]"

    if targets.length == 0 then return # Nothing to do here

    _insertMarkup _opts.classPrefix
    _overlay = document.querySelector ".#{_opts.classPrefix}__overlay"
    _wrapper = document.querySelector ".#{_opts.classPrefix}__wrapper"
    _image = document.querySelector ".#{_opts.classPrefix}__image"

    _resetCurrentImageDimensions()

    # Not jQuery => use immediatly invoked function to get a new closure
    # and add the event listener on the correct target
    for target in targets when _isValidImage target
        do (target) ->
            _$.addEvent target, "click", (evt) ->
                _$.preventDefault evt
                _setCurrentImage target

    _$.addEvent window, "resize", _resize
    _$.addEvent window, "orientationchange", _resize

    _$.addEvent _overlay, "click", _deactivate
    _$.addEvent _image, "click", _deactivate

    if _opts.useEscape
        _$.addEvent document, "keyup", (evt) ->
            evt = evt or window.event
            if evt.keyCode? and evt.keyCode == 27 then _deactivate()
