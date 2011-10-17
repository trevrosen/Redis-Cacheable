module RedisCacheable

  CONFIG_OPTIONS = [
    :namespace,
    :key_method,
    :cache_map
  ]

  def self.included(base)
    base.class_eval do
      @rc_config = {}

      class << self
        CONFIG_OPTIONS.each do |option_name|
          define_method("rc_#{option_name}") do |option_setting|
            @rc_config[option_name] = option_setting
          end

          define_method("_rc_#{option_name}") do
            @rc_config[option_name]
          end
        end

        def _rc_connection
          @rc_config[:connection] ||= Redis::Namespace.new(@rc_config[:namespace], :redis => $redis)
        end
      end # end class methods


      # --------------------------------
      # -- Instance Methods ------------
      # --------------------------------


      def rc_write!
        self.class._rc_connection.multi do
          rc_decide_and_write
        end
      end

      # Don't use directly -- use rc_write! for transactional Redis write
      def rc_convert_and_write!
        if self.class._rc_cache_map.nil?
          if self.respond_to? :to_json
            self.class._rc_connection.set(rc_cache_key, self.to_json)
          elsif self.respond_to? :to_hash
            self.class._rc_connection.set(rc_cache_key, ActiveSupport::JSON.encode(self.to_hash))
          else
            raise RedisCacheable::MaplessClassError, "can't handle without cache_map or to_hash/to_json"
          end
        else
          self.class._rc_cache_map.keys.each do |ivar|
            rc_store_ivar!(ivar)
          end
        end
      end

      def rc_read!
        r_data = redis_data
        case r_data
        when String
          self.class.new(ActiveSupport::JSON.decode(r_data))
        when Hash
          self.class.new(r_data)
        end
      end
      
      def redis_data
        case type_in_redis
        when :hash
          self.class._rc_connection.hgetall(rc_cache_key)
        when :string
          self.class._rc_connection.get(rc_cache_key)
        else :none
          []
        end
      end

      def exists_in_redis?
        self.class._rc_connection.keys(rc_cache_key)
      end

      def type_in_redis
        self.class._rc_connection.type(rc_cache_key).to_sym
      end

      def rc_cache_key
        self.send(self.class._rc_key_method).to_s
      end

      def rc_store_ivar!(ivar)
        self.class._rc_connection.hset(rc_cache_key, ivar, self.instance_variable_get("@#{ivar}").to_json)
      end
      
    end #class_eval
  end
end
