"use strict"

$(document).ready () ->
    $('header').headroom() # Headroom.js to hide the header on scroll
    $('.img img').unveil 100 # unveil.js, loads image only when user scrolls towards them