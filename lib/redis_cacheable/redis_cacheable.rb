module RedisCacheable
  def self.included(base)
    base.class_eval do
      @rc_config = Config.new
      @rc_config.namespace  = Util.underscore(base) 
      @rc_config.key_method = :id
      
      def self.rc_config
        @rc_config
      end

      def self._rc_connection
        redis_instance = defined?($redis) ? $redis : Redis.new
        @rc_config.redis_connection ||= Redis::Namespace.new(@rc_config.namespace, :redis => redis_instance)
      end


      # --------------------------------
      # -- Instance Methods ------------
      # --------------------------------


      def rc_write!
        self.class._rc_connection.multi do
          rc_convert_and_write!
        end
      end

      # Don't use directly -- use rc_write! for transactional Redis write
      def rc_convert_and_write!
        if self.class.rc_config.cache_map.nil?
          if self.respond_to? :to_json
            self.class._rc_connection.set(rc_cache_key, self.to_json)
          elsif self.respond_to? :to_hash
            puts "Going to call encode!"
            self.class._rc_connection.set(rc_cache_key, ActiveSupport::JSON.encode(self.to_hash))
          else
            raise RedisCacheable::NonConvertableClassError
          end
        else
          self.class.rc_config.cache_map.keys.each do |ivar|
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
        !self.class._rc_connection.keys(rc_cache_key).empty?
      end

      def type_in_redis
        self.class._rc_connection.type(rc_cache_key).to_sym
      end

      def rc_cache_key
        self.send(self.class.rc_config.key_method).to_s
      end

      def rc_store_ivar!(ivar)
        self.class._rc_connection.hset(rc_cache_key, ivar, self.instance_variable_get("@#{ivar}").to_json)
      end
      
    end #class_eval
  end
end
