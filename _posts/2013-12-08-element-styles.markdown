---
layout: post
title: "Element styles"
date: 2013-12-08 14:08:00
---

## A paragraph

This is a paragraph, you can have links, like [this one](http://baconipsum.com/) which will be used in this exemple page. You can have *italic* and **bold** text.

Corned beef tri-tip pig fatback meatball brisket. Filet mignon tenderloin flank kielbasa venison. Tail prosciutto shoulder, turkey cow hamburger flank pork swine beef ribs pig tri-tip short loin meatloaf beef. Brisket turducken boudin, frankfurter jowl chuck flank shank ham hock pork chop meatloaf.

## List styles

### Unordered

+ Chicken flank
+ leberkas
+ bresaola
+ short ribs
+ andouille
+ pastrami

### Ordered

1. Chicken flank
1. leberkas
1. bresaola
1. short ribs
1. andouille
1. pastrami

## Quote styles

### Simple

> This town deserves a better class of criminal and I'm gonna give it to them. Tell your men they work for me now. This is my city.

### With author name

<blockquote>
    <p>This town deserves a better class of criminal and I'm gonna give it to them. Tell your men they work for me now. This is my city.</p>
    <p class="author">Marc Jacobs</p>
</blockquote>

## Headings (this is h2)
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

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

## Types of images

### Simple image with caption

<div class="post-img">
    <img class="small" data-src="http://666a658c624a3c03a6b2-25cda059d975d2f318c03e90bcf17c40.r92.cf1.rackcdn.com/unsplash_528c8f581f45e_1.JPG" data-src-high="http://666a658c624a3c03a6b2-25cda059d975d2f318c03e90bcf17c40.r92.cf1.rackcdn.com/unsplash_528c8f581f45e_1.JPG" alt="" title="">
    <p class="legend">Pretty photo from <a href="unsplash">unsplash</a></p>
</div>

### Huge image

<div class="post-img">
    <img class="huge"
         data-src="http://666a658c624a3c03a6b2-25cda059d975d2f318c03e90bcf17c40.r92.cf1.rackcdn.com/unsplash_528cba6de78e5_1.JPG"
         alt="">
</div>

### Big image

<div class="post-img">
    <img class="big"
         data-src="http://666a658c624a3c03a6b2-25cda059d975d2f318c03e90bcf17c40.r92.cf1.rackcdn.com/unsplash_528aedf6ec3df_1.JPG"
         alt="">
</div>
