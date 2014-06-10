Tooltips = ((global, document, undefined_) ->

    "use strict"

    return (options) ->

        links = document.querySelectorAll('section.main a')
        for link in links
            href = link.getAttribute('href')
            if href then link.setAttribute('data-tooltip', href)

) this, document