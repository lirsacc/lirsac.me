---
layout: post
title: "Element styles"
date: 2013-12-08 14:08:00
---

## A paragraph

We have purged your fear. You are ready to Iead these men. You are ready to become a member of the League of Shadows. But first, you must demonstrate your commitment to justice.

You have nothing, nothing to threaten me with. Nothing to do with all your strength.

There is a prison in a more ancient part of the world. A pit where men are thrown to suffer and die. But sometimes a man rises from the darkness. Sometimes, the pit sends something back.

It's not just your name, sir. It's your father's name. And it's all that's left of him. Don't destroy it.

Tomorrow, you will be released. If you are bored of brawling with thieves and want to achieve something there is a rare blue flower that grows on the eastern slopes. Pick one of these flowers. If you can carry it to the top of the mountain, you may find what you were looking for in the first place.

---

## List styles

+ I'm adaptable.
+ You have nothing, nothing to threaten me with. Nothing to do with all your strength.
+ I'm adaptable.

1. I'm adaptable.
1. You have nothing, nothing to threaten me with. Nothing to do with all your strength.
1. I'm adaptable.

## Quotes

> This town deserves a better class of criminal and I'm gonna give it to them. Tell your men they work for me now. This is my city.

<blockquote>
    <p>This town deserves a better class of criminal and I'm gonna give it to them. Tell your men they work for me now. This is my city.</p>
    <p class="author">Marc Jacobs</p>
</blockquote>

## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

## A code block

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
