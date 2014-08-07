# Ultrasimple vanilla js image zooming script
#
# Parameters :
#     *    selector (default data-zoom)
#     *    useEscapeKey (default true)
#     *    cls (default zoomed-image)
#     *    scale (default .95)
#     *    handleReatina (defualt: true)
#
# TODO :
#     *    Add throttling on _resize, _activate & _set
#     *    Touch events
#     *    Preloading & loading spinner
#     *    Arrow keys to navigate + preloading
#     *    Handle data-legend / captions
#
# =========================================================================

Zoom = ((global, document, undefined_) ->
    "use strict"

    _obj = document.body or document.documentElement

    _scale = undefined
    _handleRetina = true
    _selector = undefined

    _active = false
    _overlay = undefined
    _wrapper = undefined
    _image = undefined

    _resetDimensions = () ->
        _image.setAttribute "style", "left: 50%; top: 50%; width: 0; height: 0"

    _calcDimensions = (img, force) ->
        force ?= false

        screenWidth = window.innerWidth or document.documentElement.clientWidth
        screenHeight = window.innerHeight or document.documentElement.clientHeight
        maxWidth = _scale * screenWidth
        maxHeight = _scale * screenHeight
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
        img.style.top = "#{(screenHeight - imgHeight) / 2}px"
        img.style.left = "#{(screenWidth - imgWidth) / 2}px"

    _set = (elem) ->
        newImg = new Image()
        if _handleRetina then newSrc = elem.getAttribute "#{_selector}-retina"
        # Always fall back to normal selector
        # in case retina attribute is not found
        if !newSrc then newSrc = elem.getAttribute _selector
        newImg.src = newSrc

        newImg.onload = () ->
            _calcDimensions newImg
            _image.src = newImg.src
            _image.style.width = newImg.style.width
            _image.style.height = newImg.style.height
            _image.style.top = newImg.style.top
            _image.style.left = newImg.style.left

        _activate()

    _resize = () ->
        unless _active and _image? then return
        _calcDimensions _image, true

    _valid = (elem) ->
        elem.tagName == "IMG"

    _createMarkup = (cls) ->
        el = document.createElement "div"
        addClass el, "#{cls}-wrapper"
        el.innerHTML = "<div class='#{cls}-overlay'></div>\
                       <img src='' class='#{cls}'/>"
        _obj.appendChild el

    _activate = () ->
        if !_image? or _active then return
        _active = true
        addClass _wrapper, "active"

    _deactivate = () ->
        unless _active then return
        _active = false
        removeClass _wrapper, "active"
        _resetDimensions()

    init = (options) ->

        options ?= {}
        _selector = options.selector or "data-zoom"
        useEscapeKey = options.useEscapeKey or true
        cls = options.cls or "zoomed-image"
        _scale = options.scale or 0.986
        _handleRetina = (options.handleRetina or _handleRetina) and window.devicePixelRatio > 1

        targets = document.querySelectorAll "img[#{_selector}]"

        if targets.length == 0 then return # Nothing to do here

        _createMarkup cls
        _overlay = document.querySelector ".#{cls}-overlay"
        _close = document.querySelector ".#{cls}-close"
        _wrapper = document.querySelector ".#{cls}-wrapper"
        _image = document.querySelector ".#{cls}"

        _resetDimensions()

        # Not jQuery => use immediatly invoked function to get a new closure
        # and add the event listener on the correct target
        for target in targets when _valid target
            do (target) ->
                addEvent target, "click", () ->
                    _set target

        window.onresize = _resize
        addEvent window, "orientationchange", _resize

        addEvent _overlay, "click", () ->
            _deactivate()

        addEvent _image, "click", () ->
            _deactivate()

        if useEscapeKey
            addEvent document, "keyup", (evt) ->
                evt = evt or window.event
                if evt.keyCode? and evt.keyCode == 27 then _deactivate()

    return init

) this, document
