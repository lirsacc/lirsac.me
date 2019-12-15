+++
title = "Using locally installed command line tools from NPM"
date = 2015-03-31
slug = "using-local-npm-cli-tools"
aliases = ["writing/using-local-npm-cli-tools/"]
template = "post.html"
+++


<aside>

###### Updated August 18, 2017
    
As of [npm@5.2.0](https://github.com/npm/npm/releases/tag/v5.2.0), `npx` is installed by default and does essentially what this post describes. 
Yarn also has the [`run`](https://yarnpkg.com/en/docs/cli/run) command which can serve the same purposes.

</aside>

<aside>

###### Updated May 10, 2015
    
Thanks to [this SO answer](http://stackoverflow.com/a/14524311), the completion is now improved and gets back to normal filenames after completing the command name. (Before it would just propose command names over and over again).

</aside>


I recently had the need to regularly run cli apps that were installed locally through npm. This didn't use to happen very often and I would install cli tools globally, but recently I've had to work on a few projects using different versions of node, which would require reinstalling the packages for every version which is not very practical.

Before we would just run `./node_modules/.bin/package` (or `$(npm bin)/package`) in the project directory. It does the job but is a bit tedious to type. Another solution, as proposed on [Stack Overflow](http://stackoverflow.com/a/15157360), is to prepend the `./node_modules/.bin` location to your `PATH`, either on the fly like proposed or when you start working in the directory, like with Python virtualenv or Ruby gemsets. Incidentally, npm [does this under the hood](http://blog.nodejs.org/2011/03/23/npm-1-0-global-vs-local-installation) when running the scripts in your `package.json` so you can use your local packages in these, but this pollutes the session's `PATH`.

As an alternative which does not pollutes the `PATH` and is quicker to type, we have wrote the following `npl` bash function:

{{ gist(url="https://gist.github.com/lirsacc/d189b11194f397ab794a") }}

Add this to your `~/.profile` or any file sourced in your shell and you can just use `npl package args...` from the project directory and it will pass `args...` to your cli tool (or fail with exit code 1 and warn you if you're not in an npm project). Alias it as you want, `npl` is just very easy to type with my right hand on a French keyboard.

The first `_npl_completion` function is just here to add tab completion by simply listing the files in the `.bin` directory, the [Advanced Bash Scripting Guide](http://tldp.org/LDP/abs/html/tabexpansion.html) is a good resource to get started on this.
