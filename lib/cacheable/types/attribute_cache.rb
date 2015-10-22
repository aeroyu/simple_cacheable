module Cacheable
  module AttributeCache
    def with_attribute(*attributes)
      options = get_arguments_options(attributes)
      self.cached_indices ||= {}
      self.cached_indices = self.cached_indices.merge(attributes.each_with_object({}) {
                                                          |attribute, indices| indices[attribute.to_sym] = Set.new
                                                      })

      class_eval do
        after_commit :expire_attribute_cache, :on => :update
        after_commit :expire_all_attribute_cache, :on => :update
      end

      attributes.each do |attribute|
        define_singleton_method("find_cached_by_#{attribute}") do |value|
          self.cached_indices[attribute.to_sym] ||= Set.new
          self.cached_indices[attribute.to_sym] << value
          Cacheable.fetch(attribute_cache_key("#{attribute}", value),options) do
            self.send("find_by_#{attribute}", value)
          end
        end

        define_singleton_method("find_cached_all_by_#{attribute}") do |value|
          self.cached_indices[attribute.to_sym] ||= Set.new
          self.cached_indices[attribute.to_sym] << value
          Cacheable.fetch(all_attribute_cache_key("#{attribute}", value),options) do
            if Cacheable.rails4?
              self.where("#{attribute}" => value).load
            else
              self.send("find_all_by_#{attribute}", value)
            end
          end
        end
      end
    end
  end
end