module Doing
  def doing(stop_value = nil, &producer)
    enumerator = Enumerator.new do |yielder|
      loop do
        value = producer.call
        break if value.eql? stop_value
        yielder.yield value
      end
    end

    LazyEnum.new(enumerator)
  end

  private
  class LazyEnum < Enumerator::Lazy
    def initialize(enum)
      super(enum) do |yielder, *values|
        yielder.yield *values
      end
    end

    def select(&predicate)
      LazyEnum.new(super(&predicate))
    end

    def map(&transformation)
      LazyEnum.new(super(&transformation))
    end

    def each(&side_effect)
      return super(){} if side_effect.nil?
      super(&side_effect)
    end

    def method_missing(method, *args)
      return select{|e| e.send(method, *args)} if predicate?(method)
      map do |e|
        if e.respond_to?(method)
          e.send(method, *args)
        else
          Kernel.send(method, e)
        end
      end
    end

    private
    def predicate?(method)
      method.to_s.end_with?("?")
    end
  end
end
