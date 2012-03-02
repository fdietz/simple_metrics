SimpleMetrics
=============

SimpleMetrics makes it easy to collect and aggregating data (specifically counters, timers and events).

It is heavily inspired by Statsd (https://github.com/etsy/statsd) from Etsy. Read the "Measure Anything, measure Everything" blog post (http://codeascraft.etsy.com/2011/02/15/measure-anything-measure-everything/) which did it for me.

Technically speaking it provides a simple UDP interface to send data to an Eventmachine based UDP Server. The data is stored in MongoDB using a Round Robin Database (RRD) scheme.

SimpleMetrics is written in Ruby and packaged as a gem.

The current version is considered ALPHA.

SimpleMetrics Client
--------------------

Commandline client:

Send a count of 5 for data point "module.test1":

		simple_metrics_client module.test1 -counter 5

Send a timing of 100ms:

		simple_metrics_client module.test1 -timing 100

doing the same, but since we expect a lot of calls we sample the data (10%):

		simple_metrics_client module.test1 -timing 100 --sample_rate 0.1

more info:
	
		simple_metrics_client --help

Ruby client API
---------------

Initialize client:

		client = SimpleMetrics::Client.new("localhost")

sends "com.example.test1:1|c" via UDP:

		client.increment("com.example.test1")

sends "com.example.test1:-1|c":

		client.decrement("com.example.test1")

sends "com.example.test1:5|c" (a counter with a relative value of 5):

		client.count("com.example.test1", 5)

sends "com.example.test1:5|c|@0.1" with a sample rate of 10%:

		client.count("com.example.test1", 5, 0.1)

sends "com.example.test1:5|g" (meaning gauge, an absolute value of 5):

		client.count("com.example.test1", 5)

sends "com.example.test1:100|ms":

		client.timing("com.example.test1")

More examples in the examples/ directory.

SimpleMetrics Server
--------------------

We provide a simple commandline wrapper using daemons gem (http://daemons.rubyforge.org/).

Start Server as background daemond:

		simple_metrics_server start

Start in foreground:

		simple_metrics_server start -t

Show Help:

		simple_metrics_server --help

Round Robin Database Principles in MongoDB
------------------------------------------

We use 4 collections in MongoDB each with more coarse timestamp buckets:
* 10 sec
* 1 min
* 10 min
* 1 day

The 10s and 1m collections are capped collections and have a fixed size. The other will store the data as long as we have sufficient disc space.

How can we map these times to graphs?

* 10 sec -> Realtime Graph  (ttl: 1 hour)
* 1 min  -> last hour       (ttl: 1 day)
* 10 min -> whole day view  (ttl: forever)
* 1 day  -> week view       (ttl: forever)

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