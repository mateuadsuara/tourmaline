module Doing
  def doing(stop_value = nil, &producer)
    Enumerator.new do |yielder|
      begin
        loop do
          value = producer.call
          break if value.eql? stop_value
          yielder.yield value
        end
      rescue Interrupt
      end
    end.lazy
  end
end
