module Doing
  def doing(stop_value = nil, &producer)
    enumerator = Enumerator.new do |yielder|
      loop do
        value = producer.call
        break if value.eql? stop_value
        yielder.yield value
      end
    end

    FluentEnumerator.new(enumerator)
  end

  private
  class FluentEnumerator
    def initialize(base_enumerator)
      @enum = Enumerator::Lazy.new(base_enumerator) do |yielder, *values|
        yielder.yield *values
      end
    end

    def next
      @enum.next
    end

    def each(&block)
      block ||= Proc.new{}
      @enum.each(&block)
    end

    def inject(*args, &block)
      @enum.send(:inject, *args, &block)
    end

    def select(*args, &block)
      self.class.new(@enum.send(:select, *args, &block))
    end

    def map(*args, &block)
      self.class.new(@enum.send(:map, *args, &block))
    end

    def take(*args, &block)
      self.class.new(@enum.send(:take, *args, &block))
    end

    def take_while(*args, &block)
      self.class.new(@enum.send(:take_while, *args, &block))
    end

    def method_missing(method, *args, &block)
      return select{|e| e.send(method, *args, &block)} if predicate?(method)
      map do |e|
        if e.respond_to?(method)
          e.send(method, *args, &block)
        else
          Kernel.send(method, *args.clone.unshift(e), &block)
        end
      end
    end

    private
    def predicate?(method)
      method.to_s.end_with?("?")
    end
  end
end
