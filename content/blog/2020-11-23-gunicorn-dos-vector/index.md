+++
title = "How to DOS a Django application with bad GET requests."
date = 2021-04-19
template = "post.html"
+++

<aside>

This article was originally published on [Thread's engineering blog](https://thread.engineering/2020-11-23-gunicorn-dos-vector/).

</aside>

Like any complex production service, Thread experiences outages and issues in production that affect our users from time to time. In order to improve our service quality we run post-mortems of these incidents to identify ways to fix the root causes and improve service reliability moving forward. This post summarises one such analysis.

Typical Django deployments geared for production are usually comprised of a WSGI server such as Gunicorn running your app, and a reverse proxy such as NGINX. The latter tend to scale better and are less susceptible to common Denial Of Service attacks; which is one of the [main reasons](https://docs.gunicorn.org/en/latest/deploy.html) to not expose your WSGI server directly.

Because WSGI servers like Gunicorn aren't built to protect from Denial Of Service attacks, it's easy to trigger DoS conditions against a Django application with even slightly malformed requests. For example, sending a request with a body smaller than the advertised `Content-Length`. If the view tries to read the body, it will hang and block the current worker. [This issue](https://code.djangoproject.com/ticket/29800) has more details. With NGINX the [`proxy_request_buffering`](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_request_buffering) setting is what protects us from this before it hits the backend.

This specific situation should not have been a problem for us given that we run behind a properly configured NGINX instance; so we were pretty surprised when we tracked down a drop in Gunicorn capacity to workers being stuck on a `read()` call and waiting for a `GET` request's body to be available [^1]. 

We tracked the original request coming into our infrastructure and at the point of hitting NGINX this requests was correct (i.e. the `Content-Length` header matched its body). This pointed to the real cause here: we'd recently introduced a Node.js based server to handle server-side rendering of our React frontend. The architecture is as follows:

- We run multiple NGINX nodes exposed to the internet. These accept requests coming into our infrastructure, distribute to various backend servers and decide whether a request should go through the Node.js SSR server or can go directly to the Gunicorn server (e.g. GraphQL API requests).
- Each backend server runs a Node.js process and a Gunicorn process. The Node.js process fronts Gunicorn, running the single page code when it can and forwarding what would have been AJAX requests, or proxying any requests it cannot handle directly as a fallback.

Requests from Node.js to Gunicorn do not go through NGINX for 2 main reasons:

1. This could introduce a routing loop if NGINX decides to redirect the request back to a Node server.
2. It ensures minimal latency between the 2 backend components by keeping them local to a single host.

The requests causing our Gunicorn workers to lock up were coming from the Node.js server because we were stripping the bodies from `GET` requests, _corrupting_ them along the way and creating what was essentially self induced Denial of Service. We do this because the Fetch API [does not allow](https://github.com/whatwg/fetch/issues/551) [sending GET request with a body](https://github.com/whatwg/fetch/issues/83) [^2]. As we never rely on this ourselves, we missed stripping the relevant headers and this was never caught in normal operations (in fact it took some malicious requests [^1] trigger this failure mode).

The fix for this was simple: 

- The root cause was fixed by making sure headers are still valid when modifying proxied requests.
- A contributing factor that was highlighted by this incident is that we were proxying some API requests through the Node.js server when they didn't need to be. This was fixed by improving our routing at the NGINX layer.


[^1]: Specifically, we were receiving malformed `GET` requests sent to our GraphQL endpoint. They had reproduced the request we make from our frontend, replaced some variables with SQL injection and then sent them as `GET`. The [library](https://docs.graphene-python.org/projects/django/en/latest/) we use attempts to read the body of the request regardless of the HTTP method. As we send all our GraphQL requests over `POST` and GraphQL over `GET` usually uses query parameters we had not encountered this particular failure mode before.

[^2]: Notably this valid HTTP/1.1 according to [RFC 7231](https://tools.ietf.org/html/rfc7231), although the semantics are undefined. This is [not valid in HTTP/2](https://tools.ietf.org/html/rfc7540#section-8.1.3).