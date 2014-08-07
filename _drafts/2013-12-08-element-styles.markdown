---
layout: post
title: Elements style guides
date: 2013-12-08 14:08:00
---

## Main styles

Corned beef tri-tip pig fatback meatball brisket. Filet mignon tenderloin flank kielbasa venison. Tail prosciutto shoulder, turkey cow hamburger flank pork swine beef ribs pig tri-tip short loin meatloaf beef. Brisket turducken boudin, frankfurter jowl chuck flank shank ham hock pork chop meatloaf.

You can use different text formats: *italic*, **bold**, _underline_, and  ~~strike through~~, `code` and [links](http://google.com).

Tooltips are automatically added with a `data-tooltip` attribute: <a href="http://google.com" data-tooltip="http://google.com">Google</a>.

Basic quotes :

> Salami rump tongue, meatloaf beef ribs turkey pastrami chuck. Fatback flank shankle ground round pork chop beef tail sausage pig venison spare ribs.

or with author :

<blockquote>
    <p>Pork chop biltong pig, jerky fatback sirloin corned beef pork drumstick andouille jowl rump prosciutto sausage beef ribs landjaeger.</p>
    <p class="author">Bacon doner boudin</p>
</blockquote>

## List styles

+ Chicken flank
+ leberkas
+ bresaola
+ short ribs
+ andouille
+ pastrami

1. Chicken flank
1. leberkas
1. bresaola
1. short ribs
1. andouille
1. pastrami

## Headings (this is h2)

Corned beef tri-tip pig fatback meatball brisket. Filet mignon tenderloin flank kielbasa venison. Tail prosciutto shoulder, turkey cow hamburger flank pork swine beef ribs pig tri-tip short loin meatloaf beef. Brisket turducken boudin, frankfurter jowl chuck flank shank ham hock pork chop meatloaf.

### Heading 3

Corned beef tri-tip pig fatback meatball brisket. Filet mignon tenderloin flank kielbasa venison. Tail prosciutto shoulder, turkey cow hamburger flank pork swine beef ribs pig tri-tip short loin meatloaf beef. Brisket turducken boudin, frankfurter jowl chuck flank shank ham hock pork chop meatloaf.

#### Heading 4

Corned beef tri-tip pig fatback meatball brisket. Filet mignon tenderloin flank kielbasa venison. Tail prosciutto shoulder, turkey cow hamburger flank pork swine beef ribs pig tri-tip short loin meatloaf beef. Brisket turducken boudin, frankfurter jowl chuck flank shank ham hock pork chop meatloaf.

## Images

Create images with the liquid tag

    {{ "{% image src=http://666a658c624a3c03a6b2-25cda059d975d2f318c03e90bcf17c40.r92.cf1.rackcdn.com/unsplash_528aedf6ec3df_1.JPG " }}%}

{% image src=http://33.media.tumblr.com/b39a844d2c755fca6b9009e557fcf88a/tumblr_n9hym20RNy1st5lhmo1_1280.jpg %}

{% image src=http://31.media.tumblr.com/01a998fe4b01eb36ffb2feb8b8905f59/tumblr_n5e6mau0Jx1st5lhmo1_1280.jpg | size=small | zoom=https://s3.amazonaws.com/ooomf-com-files/91vrBzqgSveXxB03xgrG_patterns.jpg %}

{% image src=http://31.media.tumblr.com/b92879483bd60c7db0871cc64b694b05/tumblr_n9hyqfJavs1st5lhmo1_1280.jpg | size=huge | no_zoom %}

## Code blocks through pygments

{% highlight coffee %}
fs = require 'fs'

# Config
# ---------------

# Defaults
tables = 12
maxPerTable = 8
rounds = 3
filename = 'data.csv'
maxSameDept = 2
maxSameRound = 1
verbose = false

# Override from command line arguments
# There surely is a better way to do this but this lazy parsing works
args = process.argv.slice 2

i = 0
while i <= args.length - 1
    switch args[i]
        when "-t" then tables = args[i+1]
        when "-p" then maxPerTable = args[i+1]
        when "-f" then filename = args[i+1]
        when "-R" then rounds = args[i+1]
        when "-d" then maxSameDept = args[i+1]
        when "-r" then maxSameRound = args[i+1]
        when "-v"
            verbose = true
            i-= 1
    i+= 2

console.log "Options :\n\t#{rounds} rounds of #{tables} tables (max #{maxPerTable} people).
{% endhighlight %}
