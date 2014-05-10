# Ultrasimple vanilla js image zooming script
#
# Parameters :
#     *    selector (default data-zoom)
#     *    useEscapeKey (default true)
#     *    cls (default .zoomed-image)
#     *    scale (default .95)
#
# TODO :
#     *    Touch events
#     *    Preloading & loading spinner
#     *    Arrow keys to navigate + preloading
#     *    Handle data-legend

window.Zoom = ((global, document, undefined_) ->
    "use strict"

    _obj = document.body or document.documentElement
    _w = window
    _typesRegEx = new RegExp('\.(png|jpg|jpeg|gif)$', 'i')

    _overlay = undefined
    _wrapper = undefined
    _image = undefined
    _scale = undefined
    _selector = undefined
    _active = false

    _calcDimensions = (img, force) ->
        unless force? then force = false
        screenWidth = _w.innerWidth
        screenHeight = _w.innerHeight
        screenRatio = screenWidth / screenHeight

        imgWidth = img.width
        imgHeight = img.height
        imgRatio = imgWidth / imgHeight

        if imgWidth > _scale * screenWidth or imgHeight > _scale * screenHeight or force
            if imgRatio > screenRatio
                imgWidth = _scale * screenWidth
                imgHeight = imgWidth / imgRatio
            else
                imgHeight = _scale * screenHeight
                imgWidth = imgRatio * imgHeight

        img.style.width = "#{imgWidth}px"
        img.style.height = "#{imgHeight}px"
        img.style.top = "#{(screenHeight - imgHeight) / 2}px"
        img.style.left = "#{(screenWidth - imgWidth) / 2}px"

    _set = (elem) ->
        newImg = new Image()
        newImg.src = elem.getAttribute _selector

        newImg.onload = () ->
            _calcDimensions newImg
            _image.src = newImg.src
            _image.style.width = newImg.style.width
            _image.style.height = newImg.style.height
            _image.style.top = newImg.style.top
            _image.style.left = newImg.style.left
            _activate()

    _updateActive = () ->
        unless (_active and _image?) then return
        _calcDimensions _image, true

    _valid = (elem) ->
        elem.tagName == "IMG" and _typesRegEx.test elem.getAttribute _selector

    _createMarkup = (cls) ->
        str = "<div class='#{cls}-overlay'></div><img src='' class='#{cls}'/><div class='#{cls}-close'></div>"
        el = document.createElement "div"
        el.innerHTML = str
        addClass el, "#{cls}-wrapper"
        _obj.appendChild el

    _activate = () ->
        if !_image? or _active then return
        _active = true
        addClass _wrapper, "active"

    _deactivate = () ->
        unless _active then return
        _active = false
        removeClass _wrapper, "active"

    init = (options) ->
        unless options? then options = {}
        _selector = options.selector or "data-zoom"
        useEscapeKey = options.escapeKey or true
        cls = options.cls or "zoomed-image"
        _scale = options.scale or 0.95

        targets = document.querySelectorAll "img[#{_selector}]"

        if targets.length == 0 then return

        _createMarkup cls
        _overlay = document.querySelector ".#{cls}-overlay"
        _close = document.querySelector ".#{cls}-close"
        _wrapper = document.querySelector ".#{cls}-wrapper"
        _image = document.querySelector ".#{cls}"

        # Not jQuery => use invoked functions to get a new closure and
        # add the event listener on the correct element
        for i in [0..targets.length - 1]
            if _valid targets[i]
                do (i) ->
                    addEvent targets[i], "click", () ->
                        _set targets[i]

        window.onresize = _updateActive
        addEvent window, "orientationchange", _updateActive

        addEvent _overlay, "click", () ->
            _deactivate()

        addEvent _image, "click", () ->
            _deactivate()

        addEvent _close, "click", () ->
            _deactivate()

        if useEscapeKey
            addEvent document, "keyup", (evt) ->
                evt = evt or window.event
                if evt.keyCode? and evt.keyCode == 27 then _deactivate()

    return init

) this, document
