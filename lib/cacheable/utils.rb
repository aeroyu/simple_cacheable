module Cacheable
  module Utils
    def get_arguments_options(arguments)
      options= {}
      arg_tmp=[]
      arguments.each do |arg|
        if arg.is_a?(Hash)
          options=arg if options.empty?
        else
          arg_tmp << arg
        end
      end
      arguments=arg_tmp
      options
    end
  end
end