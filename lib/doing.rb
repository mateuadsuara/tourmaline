require_relative 'doing/fluent_enumerator'

module Doing
  def doing(stop_value = nil, &block)
    raise ArgumentError.new('No block given') unless block_given?

    FluentEnumerator.new(build_enumerator(stop_value, block))
  end

  private
  def build_enumerator(stop_value, block)
    Enumerator.new do |caller|
      loop do
        value = block.call
        break if value.eql? stop_value
        caller.yield value
      end
    end
  end
end
