# RedisCacheable stuff
require "redis_cacheable/version"
require "redis_cacheable/redis_cacheable"

# Other fine libs
require "redis"
require "redis-namespace"

# Turn on a Redis instance
$redis = Redis.new

