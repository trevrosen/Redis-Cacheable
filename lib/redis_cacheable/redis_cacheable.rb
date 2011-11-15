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

      def rc_cache_key
        self.send(self.class.rc_config.key_method).to_s
      end
      
    end #class_eval
  end
end
