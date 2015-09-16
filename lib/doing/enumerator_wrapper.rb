module Doing
  module EnumeratorWrapper
    def wrap(*method_names)
      method_names.each do |method_name|
        define_method(method_name.to_s) do |*args, &block|
          self.class.new(enumerator.send(method_name, *args, &block))
        end
      end
    end
  end
end
