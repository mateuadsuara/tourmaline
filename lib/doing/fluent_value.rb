module Doing
  class FluentValue < BasicObject
    attr_reader :it

    def initialize(it)
      @it = it
    end

    def method_missing(method, *args, &block)
      result = if it.respond_to?(method)
        it.send(method, *args, &block)
      else
        ::Kernel.send(method, *args.clone.unshift(it), &block)
      end
      FluentValue.new(result)
    end
  end
end
