#Redis Cacheable

Nothing to see here just yet.  Move along.  Move along.

When it's ready, here's the basics of what RC will provide:

RedisCacheable offers a generic way to cache objects that are basically
composites of scalars, strings, and other data that can be converted to
JSON.  The library grew from a business need to provide a way to crunch 
numbers for a "dashboard" out-of-band from the work required to merely
serve the webpage that displays these stats.

RC might be a good choice for you if:

* You have a bunch of data that has to be aggregated/crunched on a
  regular basis and can easily be gathered into one top-level
"composite" object

* You're able to implement an updating task on a background queue (such
  as [delayed_job](tobi/delayed_job) or [Resque](defunkt/resque)

* Your main concern is ensuring that end users don't have to wait for
  numbers to be crunched in real time

* You want as minimal a way as possible to cache this data (you don't
  care about LRU, etc))
