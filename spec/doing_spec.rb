require 'doing'

RSpec.describe Doing do
  include Doing

  describe 'doing' do
    it 'iterates with the values returned by the block until is nil' do
      values = [1, 2, 3, nil, 5]
      enumerator = doing{values.shift}
      expect(enumerator.next).to eq(1)
      expect(enumerator.next).to eq(2)
      expect(enumerator.next).to eq(3)
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'iterates until the block returns the explicit stop value' do
      values = ['1', :stop_value, '3']
      enumerator = doing(:stop_value){values.shift}
      enumerator.next
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'lets the raised errors bubble up' do
      enumerator = doing{raise "error from iteration"}
      expect{enumerator.next}.to raise_error("error from iteration")
    end

    it 'iterates lazily' do
      values = [
        ->(){1},
        ->(){raise "should not be evaluated"}
      ]
      enumerator = doing{values.shift.call}.map{|v| v+1}
      expect(enumerator.next).to eq(2)
    end
  end
end
