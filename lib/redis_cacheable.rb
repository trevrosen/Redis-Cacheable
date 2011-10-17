require "redis_cacheable/version"
require "redis_cacheable/redis_cacheable"

require "active_support"
require "redis"
require "redis-namespace"


module RedisCacheable
  # raised when RC can't figure out how to create cacheable (JSON) data
  class MaplessClassError < Exception; end
end
