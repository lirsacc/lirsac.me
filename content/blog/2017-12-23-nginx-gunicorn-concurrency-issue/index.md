+++
title = "Concurrency limits and kernel settings when running NGINX & Gunicorn"
slug = "concurrency-limits-and-kernel-settings-when-running-nginx-gunicorn"
aliases = [
  "writing/concurrency-limits-and-kernel-settings-when-running-nginx-gunicorn",
]
date = 2017-12-23
template = "post.html"
+++

A few weeks ago the team I work on at [Stylight](https://tech.stylight.com/) encountered an unexpected concurrency issue with one of our services. While this specific issue turned out to be simple, we didn't find much information putting it all together online and thought our experience would be worth sharing.

<!-- more -->

## The problem

After going to production and coming under increased load, one of our web services used for financial reporting started dropping requests with `502 (Bad Gateway)` response codes alongside the following error message from NGINX:

```
connect() to unix:/run/gunicorn.socket failed (11: Resource temporarily unavailable)
```

A quick 10s load test performed with [vegeta](https://github.com/tsenart/vegeta) confirmed that the problem started appearing around 20 req/s while both the NGINX and Gunicorn configurations were setup to handle much more than that and did so when ran locally against the production database.

Running the service in docker locally however exhibited the same problem as production. After some head scratching, we were tipped off the real problem by [this paragraph](http://docs.gunicorn.org/en/stable/faq.html?highlight=somaxconn#how-can-i-increase-the-maximum-socket-backlog) from Gunicorn's documentation:

> **How can I increase the maximum socket backlog?**  
> Listening sockets have an associated queue of incoming connections that are waiting to be accepted. If you happen to have a stampede of clients that fill up this queue new connections will eventually start getting dropped.

Turns out the issue is quite simple: when using NGINX as a reverse proxy through a unix socket, the unix socket connection queue size (controlled by the `net.core.somaxconn` kernel setting on Linux machines) is the bottleneck regardless of NGINX's and / or the upstream's configured capacity (in our case Gunicorn backlog queue size). In practice, NGINX will hand over the requests to the socket, and when the socket's queue is full, it starts refusing requests leading NGINX to drop subsequent requests with the status code `502 (Bad Gateway)`. The number of workers (at either the NGINX or Gunicorn level) doesn't help as everything goes through the same socket.

You can find code and instructions to reproduce the problem in a minimal way in [this Github repository](https://github.com/lirsacc/nginx-gunicorn-somaxconn-reproduction).

## The solution

As we run our services in Docker on AWS's infrastructure, we needed to figure out where the `net.core.somaxconn` setting was being limited. Turns out it is set to 128 by default in both docker containers and on Amazon's default Ubuntu AMIs. It can be tweaked with the following commands:

* For Linux machines, run `sysctl -w net.core.somaxconn=...` (may require root access).
* When running inside docker containers, you need to call `docker run` with the `--sysctl net.core.somaxconn=...` flag set correctly. Refer to the [relevant docker documentation](https://docs.docker.com/engine/reference/commandline/run/#configure-namespaced-kernel-parameters-sysctls-at-runtime) for more information.

**Disclaimer:** The default setting of 128 queued connections per socket should work for most applications with fast transactions, and the problem only affects very high concurrency servers and / or applications which expect to wait on blocking I/O and queue up a lot of requests. This was the case for us with reporting queries expected to potentially run in minutes, in which case being able to queue and delay some users was preferable than dropping their requests. A higher setting should not be a problem for most applications with fast transactions; however increasing the TCP queue size could hide some downstream latency issues and failing early may be better. As always consider your specific use-case and whether this is an unavoidable problem to be solved or a symptom of a deeper issue (design, architecture, etc.).

In the end while the issue turned out pretty simple and straightforward once we knew where to look, this served as a good reminder that even when running in cloud infrastructure understanding the underlying tech is as important as ever.

## Further reading

Here are some interesting links to dive more into related topics:

* Background on TCP socket: [http://veithen.github.io/2014/01/01/how-tcp-backlog-works-in-linux.html](http://veithen.github.io/2014/01/01/how-tcp-backlog-works-in-linux.html)
* Netflix write-ups on configuring Linux servers on AWS:
  * [https://www.slideshare.net/AmazonWebServices/pfc306-performance-tuning-amazon-ec2-instances-aws-reinvent-2014](https://www.slideshare.net/AmazonWebServices/pfc306-performance-tuning-amazon-ec2-instances-aws-reinvent-2014)
  * [http://www.brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html](http://www.brendangregg.com/blog/2015-03-03/performance-tuning-linux-instances-on-ec2.html)
* Some more write-ups on NGINX specific configuration:
  * [https://www.linode.com/docs/web-servers/nginx/configure-nginx-for-optimized-performance/](https://www.linode.com/docs/web-servers/nginx/configure-nginx-for-optimized-performance/)
  * [http://engineering.chartbeat.com/2014/01/02/part-1-lessons-learned-tuning-tcp-and-nginx-in-ec2/](http://engineering.chartbeat.com/2014/01/02/part-1-lessons-learned-tuning-tcp-and-nginx-in-ec2/)
