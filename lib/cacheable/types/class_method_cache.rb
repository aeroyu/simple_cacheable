module Cacheable
  module ClassMethodCache
    # Cached class method
    # Should expire on any instance save
    def with_class_method(*methods)
      @options = get_arguments_options(methods)

      self.cached_class_methods ||= {}
      self.cached_class_methods = self.cached_class_methods.merge(methods.each_with_object({}) {
        |meth, indices| indices[meth.to_sym] = Set.new
      })

      class_eval do
        after_commit :expire_class_method_cache, :on => :update
      end

      methods.each do |meth|
        define_singleton_method("cached_#{meth}") do |*args|
          self.cached_class_methods[meth.to_sym] ||= Set.new
          self.cached_class_methods[meth.to_sym] << args
          Cacheable.fetch class_method_cache_key(meth, args),@options do
            self.method(meth).arity == 0 ? send(meth) : send(meth, *args)
          end
        end
      end
    end
  end
end