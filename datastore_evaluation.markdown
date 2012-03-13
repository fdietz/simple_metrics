h1. Datastore Evaluation

h3. Use cases
* retrieve list of all metric names
* search/autocomplete metric names
* show metric in minute, hour, day, week view
* automatic eviction of metrics after TTL configured per bucket
* unix timestamp and metric name should have a unique constraint per retention

h3. Calculate Data Size

For 1 metric we store:
* 10s data for 1 hours (3.600 data points)
* 1m data for 10 hours (600 data points)
* 10m data for 5 days (600 data points)
* 1 hour data for 5 months (480 data points)
=> 5280 data points

h2. Redis

h3. Datastructure

Use sorted set for all buckets * metric names:
* jobs.posting.click:10s
* jobs.posting.click:1m
* jobs.posting.click:10m
* jobs.posting.click:1h

* use unix timestamp as key
* use expire with bucket-specific TTL
* use set to store all metric names
* eviction for free if we can use expire with a ttl setting or ltrim command
* all data in memory?? 

h2. MongoDB

* Use collections for eachbuckets. 
* Capped collections for 10s and 1m. 
* Normal collections for 10m and 1 hour retention.
* use additional collection to store all metric names and properties

* eviction for free based on capped collection (but size needs to be configured by admin, not user friendly)
* fire and forget write operations is nice
* atomic updates