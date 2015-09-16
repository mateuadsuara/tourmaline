require 'forwardable'
require_relative 'enumerator_wrapper'

module Doing
  class FluentEnumerator
    extend EnumeratorWrapper
    extend Forwardable

    def_delegators :enumerator, :next, :inject
    wrap :take_while, :take, :map, :select

    def initialize(enumerator)
      @enumerator = enumerator.lazy
    end

    def each(&block)
      block ||= Proc.new{}
      enumerator.each(&block)
    end

    def method_missing(method, *args, &block)
      if predicate?(method)
        select_elements(method, *args, &block)
      else
        map_elements(method, *args, &block)
      end
    end

    private
    attr_reader :enumerator

    def predicate?(method)
      method.to_s.end_with?("?")
    end

    def select_elements(method, *args, &block)
      select{|e| e.send(method, *args, &block)}
    end

    def map_elements(method, *args, &block)
      map do |e|
        if e.respond_to?(method)
          e.send(method, *args, &block)
        else
          Kernel.send(method, *args.clone.unshift(e), &block)
        end
      end
    end
  end
end
