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
          # setters
          define_method("rc_#{option_name}") do |option_setting|
            @rc_config[option_name] = option_setting
          end

          # getters
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
       if self.class._rc_cache_map.nil?
         if self.respond_to? :to_json
           self.class._rc_connection.set(rc_cache_key, self.to_json)
         elsif self.respond_to? :to_hash
           self.class._rc_connection.set(rc_cache_key, self.to_hash.to_json)
         else
           # build by calling to_json on each instance variable
           # NOTE: how expensive is this?
         end

       # assume cache map is instance variables
       # TODO: what could be bad about that? 
       else
       end
      end

      def rc_read
        
      end
      
      def exists_in_redis?
        self.class._rc_connection.keys(rc_cache_key)
      end

      def rc_cache_key
        self.send(self.class._rc_key_method).to_s
      end

      
    end #class_eval
  end
end
