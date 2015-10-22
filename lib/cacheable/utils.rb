module Cacheable
  module Utils
    def get_arguments_options(arguments)
      options=arguments.detect{|x|x.is_a?(Hash)}
      arguments.reject!{|x|x.is_a?(Hash)}
      options ||{}
    end
  end
end