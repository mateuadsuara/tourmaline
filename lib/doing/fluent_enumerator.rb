require 'forwardable'
require_relative 'enumerator_wrapper'
require_relative 'fluent_value'

module Doing
  class FluentEnumerator
    extend EnumeratorWrapper
    extend Forwardable

    def_delegators :enumerator, :next
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

    def inject(*args, &block)
      FluentValue.new(enumerator.send(:inject, *args, &block))
    end
    alias_method :reduce, :inject

    private
    attr_reader :enumerator

    def predicate?(method)
      method.to_s.end_with?("?")
    end

    def select_elements(method, *args, &block)
      select do |e|
        if e.respond_to?(method)
          e.send(method, *args, &block)
        elsif e.respond_to?(remove_question_marks(method))
          e.send(remove_question_marks(method), *args, &block)
        end
      end
    end

    def remove_question_marks(method)
      method.to_s.gsub(/\?/, "")
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
