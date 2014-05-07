---
layout: post
published: false
title: "Host a Jekyll site on Amazon S3 with Github & Travis CI"
date: 2014-05-05
---

As I said in my first post, this site is built by [Jekyll](http://jekyllrb.com/) and hosted on [Amazon S3](http://aws.amazon.com/s3/ "Amazon S3") and its source on [Github](https://github.com/lirsacc/lirsac.me/ "Git repo of lirsac.me") and deployed on push through [Travis CI](https://travis-ci.org/lirsacc/lirsac.me) to mimick Github Pages' ease of use.

This was an experiment to see if I could get it working in a few hours, and as it is free (at least for the moment), if you accept the added setup, it makes a good alternative to Github Pages in my opinion.

## Grunt

Even though Jekyll is ruby based, I am used to the [Grunt](http://gruntjs.com/) & [Bower](http://bower.io/) so I stuck with it for this website. It adds some config, which you could do without given the small size. I've had to fiddle around a bit with the Gemfile and ruby dependencies at first but hopefully most changes should only affect `package.json` / `bower.json` and `Gruntfile.coffee`.

In my case, the Gruntfile defines tasks for compiling `.coffee` and `.scss` files, adds browser prefixes through [autoprefixer](https://github.com/ai/autoprefixer) and wraps the Jekyll build with a build and dev config. (Plus some added sugar like cleaning directories, watching and serving files during dev and notifying with Growl). It works without a hitch, though I'd be interested to convert it to [Gulp](http://gulpjs.com/) to try it out.

## Amazon setup

I was pleasantly surprised to see that serving a static website out of a S3 bucket was extremely easy. The only annoying part was the payment verification which takes some time and requires a working credit card, not really an issue but can be a dealbreaker and definitely loosing in usability compared to Github Pages.

If you don't have an AWS account, go [here](http://aws.amazon.com/ "AWS home page") and click *Sign Up*, it will ask you for the usual (name, email, password) and if I remember correctly you then reach the billing step where you have to enter your credit card details and enter a code given to you through an automated phone call. The free account gives you access to [Amazon's free tier](http://aws.amazon.com/free/) for a year, which should be way more than most people need for a simple blog.

### Setting up the buckets

Once you have access to your [Amazon console](https://console.aws.amazon.com/s3/), create two buckets in the region of your choice, named after your domain (in my case *lirsac.me* for main zone apex domain and *www.lirsac.me* for the usual domain). This is just to makes sure both domain are accessible, though you might not need it if you use a CDN service like [Cloudfront](http://aws.amazon.com/cloudfront/) or [Cloudflare](http://www.cloudflare.com/). Setup logging if you want, but if you don't need access logs or already use google analytics, clicky etc., you can forget it and limit the S3 storage you will use. Once the bucket is created select it click on the *Properties* link in the top right corner, you can then setup static hosting like so:

{% image src=/img/posts/host-a-jekyll-site-on-amazon-s3-with-github-travis-ci/bucket_settings.png %}

If you have already an index page, you should be able to access your bucket (apex or no) at the *Endpoint* url (Try [this](http://lirsac.me.s3-website-eu-west-1.amazonaws.com) for example). As I don't use any CDN, I set up the second non-apex bucket to redirect over to the first one:

{% image src=/img/posts/host-a-jekyll-site-on-amazon-s3-with-github-travis-ci/bucket_redirect.png size=small %}

That's it for the S3 part, for more information the [Amazon doc](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html) is pretty extensive with examples for virtually anything. Next up is setting up your domain so that you can access your website with the correct urls.

### Pointing your domain to the bucket

There are plenty of ways to point your domain to you S3 bucket, the simplest in my opinion was using Amazon's own [Route 53](http://aws.amazon.com/route53/). To get started, create a hosted zone in the Route 53 console, it should appear like so:

{% image src=/img/posts/host-a-jekyll-site-on-amazon-s3-with-github-travis-ci/hosted_zone_overview.png %}

Next update your registar with the DNS servers given in the *Delegation Set* section to allow Route 53 to manage your domain. To point your domain just click *Create a Record Set* select *A -IPv4*, then select the *Alias* checkbox and you should be prompted with the correct bucket address. Do the same for both bucket and you're all set, just wait for the DNS to update (depends on your TTL/Refresh rate) and you should have access to your files on the apex domain and non apex domain.

## Getting deploy on push to work

### s3_website

To automate the upload to S3, there is a very useful command line tool called [s3_website](https://github.com/laurilehmijoki/s3_website) by Lauri Lehmijoki which is pretty simple to set-up. It also discoveres the `_site` directories if you're running a Jekyll site.
It can be installed as a Ruby gem, and config is stored in a `s3_website.yml` file (You can create a starter file by running `s3_website cfg create` in your project directory).

My config file is pretty standard and looks like this at the moment:

{% highlight yaml %}

s3_id: <%= ENV['S3_KEY'] %>
s3_secret: <%= ENV['S3_SECRET'] %>
s3_bucket: lirsac.me
s3_endpoint: eu-west-1
max_age: 120
gzip: true

{% endhighlight %}

There are a lot more options available (Cloudfront cache invalidation, excluding and ignoring files, reduced redundancy...), but those work for a simple blog. It just sets the credentials, bucket name and S3 region (see [available values](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region "Available S3 Regions")), plus activates gzipping of all files.Note that the `s3_id` and `s3_key` values are read from your environment variables which will be useful to run this on Travis without exposing your credentials.

To push to S3, just run `s3_website push` or `s3_website push --headless` (delete files from S3 which are missing on the local site without prompt) from the project directory.

### Setting up Travis

