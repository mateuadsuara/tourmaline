module Doing
  def doing(stop_value = nil, &producer)
    Enumerator.new do |yielder|
      loop do
        value = producer.call
        break if value.eql? stop_value
        yielder.yield value
      end
    end.lazy
  end
end
