---
template: post.hbs
title: Elements
date: 2013-12-08
draft: true
---

## Main styles

Corned beef tri-tip pig fatback meatball brisket. Filet mignon tenderloin flank kielbasa venison. Tail prosciutto shoulder, turkey cow hamburger flank pork swine beef ribs pig tri-tip short loin meatloaf beef. Brisket turducken boudin, frankfurter jowl chuck flank shank ham hock pork chop meatloaf.

You can use different text formats: *italic*, **bold**, _underline_, and  ~~strike through~~, `code` and [links](http://google.com).

Basic quotes :

> Salami rump tongue, meatloaf beef ribs turkey pastrami chuck. Fatback flank shankle ground round pork chop beef tail sausage pig venison spare ribs.

or with author :

{{{quote author='Bacon doner' content='Pork chop biltong pig, jerky fatback sirloin corned beef pork drumstick andouille jowl rump prosciutto sausage beef ribs landjaeger.'}}}

## List styles

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

{{{image 'http://33.media.tumblr.com/b39a844d2c755fca6b9009e557fcf88a/tumblr_n9hym20RNy1st5lhmo1_1280.jpg' }}}

{{{image 'http://31.media.tumblr.com/01a998fe4b01eb36ffb2feb8b8905f59/tumblr_n5e6mau0Jx1st5lhmo1_1280.jpg' size='small' zoom='https://s3.amazonaws.com/ooomf-com-files/91vrBzqgSveXxB03xgrG_patterns.jpg' }}}

{{{image 'http://31.media.tumblr.com/b92879483bd60c7db0871cc64b694b05/tumblr_n9hyqfJavs1st5lhmo1_1280.jpg' size='huge' noZoom='true' }}}

## Code blocks

Use normal markdown code blocks with the language code.

```js
function loadMetadata (dir, ext) {
    var data = {};
    fs.readdirSync(path.join(__dirname, 'src', dir)).forEach(function (file) {
        if (!file.indexOf(ext)) return;
        data[file.replace('.' + ext, '')] = path.join(dir, file);
    });
    return data;
};
```
