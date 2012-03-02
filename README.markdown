h2. SimpleMetrics Client

h3. Commandline client:

		./bin/simple_metrics_client module.test1 -c5

h3. Ruby client:

		client = SimpleMetrics::Client.new("localhost")
		# com.example.test1:1|c
		client.increment("com.example.test1")

More examples in the examples/ directory.

h2. SimpleMetrics Server

h3. Start Server

		./bin/simple_metrics_server start

h3. Show Help

		./bin/simple_metrics_server --help

h3. Round Robin Database Principles in MongoDB

We use 4 collections in MongoDB each with more coarse timestamp buckets:
* 10 sec
* 1 min
* 10 min
* 1 day

The 10s and 1m collections are capped collections and have a fixed size. The other will store the data as long as we have sufficient disc space.

Example: Timestamp for 2. Feb 2012 12:00:00

10 sec buckets:
* 2. Feb 2012 12:00:00
* 2. Feb 2012 12:00:10
* 2. Feb 2012 12:00:20
...
* 2. Feb 2012 12:01:00
* 2. Feb 2012 12:01:10

These 10s bucket entries are represented again in the 1 min bucket
* 2. Feb 2012 12:00:00
* 2. Feb 2012 12:01:00

And in the 5 min bucket:
* 2. Feb 2012 12:00:00 
* 2. Feb 2012 12:10:00 (empty in this example)

and in the 1 day bucket:
* 2. Feb 2012 12:00:00
* 3. Feb 2012 12:00:00 (empty in this example)
* 4. Feb 2012 12:00:00 (empty in this example)

h3. How can we map these times to graphs?

* 10 sec -> Realtime Graph  (ttl: 1 hour)
* 1 min  -> last hour       (ttl: 1 day)
* 10 min -> whole day view  (ttl: forever)
* 1 day  -> week view       (ttl: forever)
