require 'forwardable'

module Doing
  def doing(stop_value = nil, &block)
    raise ArgumentError.new('No block given') unless block_given?

    FluentEnumerator.new(build_enumerator(stop_value, block))
  end

  private
  def build_enumerator(stop_value, block)
    Enumerator.new do |yielder|
      loop do
        value = block.call
        break if value.eql? stop_value
        yielder.yield value
      end
    end
  end

  module EnumeratorWrapper
    def delegate_wrapping(*method_names)
      method_names.each do |method_name|
        define_method(method_name.to_s) do |*args, &block|
          self.class.new(@enum.send(method_name, *args, &block))
        end
      end
    end
  end

  class FluentEnumerator
    extend EnumeratorWrapper
    extend Forwardable

    def_delegators :@enum, :next, :inject
    delegate_wrapping :take_while, :take, :map, :select

    def initialize(base_enumerator)
      @enum = Enumerator::Lazy.new(base_enumerator) do |yielder, *values|
        yielder.yield *values
      end
    end

    def each(&block)
      block ||= Proc.new{}
      @enum.each(&block)
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
