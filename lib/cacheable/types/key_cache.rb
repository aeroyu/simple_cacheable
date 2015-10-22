module Cacheable
  module KeyCache
    def with_key(args=[])
      @options = get_arguments_options(args)

      self.cached_key = true

      class_eval do
        after_commit :expire_key_cache, on: :update
      end

      define_singleton_method("find_cached") do |id|
        cache_key = self.instance_cache_key(id)
        Cacheable.fetch(cache_key,@options) do
          self.find(id)
        end
      end
    end
  end
end