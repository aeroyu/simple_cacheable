require 'uri'
require "cacheable/utils"
require "cacheable/caches"
require "cacheable/keys"
require "cacheable/expiry"
require "cacheable/model_fetch"
require "cacheable/railtie"

module Cacheable
  extend ModelFetch

  def self.included(base)
    base.extend(Cacheable::Caches)
    base.send :include, Cacheable::Keys
    base.send :include, Cacheable::Expiry
    base.send :extend,  ClassMethods

    base.class_eval do
      class_attribute   :cached_key,
                        :cached_indices,
                        :cached_methods,
                        :cached_class_methods,
                        :cached_associations
    end
  end

  def self.escape_punctuation(string)
    string.sub(/\?\Z/, '_query').sub(/!\Z/, '_bang')
  end

  def self.rails4?
    ActiveRecord::VERSION::MAJOR >= 4
  end

  module ClassMethods
    def model_cache(&block)
      instance_exec &block
    end
  end

end