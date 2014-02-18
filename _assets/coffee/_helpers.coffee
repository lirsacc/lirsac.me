addClass = (elem, className) ->
    if elem.classList
        elem.classList.add className
    else
        elem.className += ' ' + className

removeClass = (elem, className) ->
    if el.classList
        el.classList.remove className
    else
        el.className = el.className.replace(new RegExp('(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ')