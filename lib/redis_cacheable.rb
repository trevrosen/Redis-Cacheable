require "redis_cacheable/version"
require "redis_cacheable/redis_cacheable"

require "active_support"
require "ostruct"
require "redis-namespace" # Redis gem is dependency of redis-namespace

module RedisCacheable
  class NonConvertableClassError < Exception; end
  class Config < OpenStruct; end

  module Util
    class << self
      def underscore(base)
        ActiveSupport::Inflector.underscore(base)
      end
    end
  end
end
