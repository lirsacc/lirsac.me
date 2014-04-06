hasClass = (elem, className) ->
    if elem.classList
        el.classList.contains className
    else
        new RegExp('(^| )' + className + '( |$)', 'gi').test elem.className

toggleClass = (elem, className) ->
    if elem.classList
        elem.classList.toggle(className)
    else
        classes = elem.className.split ' '
        existingIndex = classes.indexOf(className)

        if existingIndex >= 0
            classes.splice existingIndex, 1
        else
            classes.push className

        elem.className = classes.join ' '

addClass = (elem, className) ->
    if elem.classList
        elem.classList.add className
    else
        elem.className += ' ' + className

removeClass = (elem, className) ->
    if elem.classList
        elem.classList.remove className
    else
        elem.className = elem.className.replace(new RegExp('(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ')

addEvent = (element, eventName, callback) ->
    if element.addEventListener
        element.addEventListener eventName, callback, false
    else if element.attachEvent
        element.attachEvent "on#{eventName}", callback
    else
        element["on#{eventName}"] = callback

removeEvent = (element, eventName, callback) ->
    if element.removeEventListener
        element.removeEventListener "#{eventName}", callback
    else if element.detachEvent
        element.detachEvent "on#{eventName}", callback
    else
        element["on#{eventName}"] = undefined
