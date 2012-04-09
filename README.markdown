SimpleMetrics
=============

SimpleMetrics makes it easy to collect and aggregate data (specifically counters, timers and events).

It is heavily inspired by Statsd (https://github.com/etsy/statsd) from Etsy. Read the "Measure Anything, measure Everything" blog post (http://codeascraft.etsy.com/2011/02/15/measure-anything-measure-everything/) which did it for me.

Technically speaking it provides a simple UDP interface to send data to an Eventmachine based UDP Server. The data is stored in MongoDB using a Round Robin Database (RRD) scheme.

SimpleMetrics is written in Ruby and packaged as a gem.

The current version is considered ALPHA.

SimpleMetrics Server
--------------------

We provide a simple commandline wrapper using daemons gem (http://daemons.rubyforge.org/).

Start Server as background daemon:

    simple_metrics_server start

Start in foreground:

    simple_metrics_server start -t

Show Help:

    simple_metrics_server --help

SimpleMetrics Web App
-----------------

A small Sinatra app is provided using the vegas gem (https://github.com/quirkey/vegas).

Start web app as background daemon:

    simple_metrics_web

Start in foreground:

    simple_metrics_web -F

Show Help:

    simple_metrics_web --help

Round Robin Database Principles in MongoDB
------------------------------------------

We use 4 collections in MongoDB each with more coarse timestamp buckets:
* 10 sec
* 1 min
* 10 min
* 1 day

The 10sec and 1min collections are capped collections and have a fixed size. The others will store the data as long as there is sufficient disc space.

How can we map these times to graphs?

* 10 sec, near real-time graph  (ttl: several hours)
* 1 min, last hour       (ttl: several days)
* 10 min, whole day view  (ttl: forever)
* 1 day , week view       (ttl: forever)

License 
-------

(The MIT License)

Copyright (c) 2012 Frederik Dietz <fdietz@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.