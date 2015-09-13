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

    it 'can do something with each value' do
      values = [1, 2, 3, 4]
      acc = 0
      returned_after_each = doing{values.shift}.each{|v| acc += v}
      expect(acc).to eq(10)
      expect(returned_after_each).to be(nil)
    end

    it 'consumes the lazyness when called each without a block' do
      values = [1, 2, 3, 4]
      acc = 0
      enumerator = doing{values.shift}.map{|v| acc += v; v}
      expect(acc).to eq(0)
      returned_after_each = enumerator.each
      expect(acc).to eq(10)
      expect(returned_after_each).to be(nil)
    end

    it 'selects the elements that match a predicate finished in ?' do
      values = ["ab", "ac", "bb", "bc"]
      enumerator = doing{values.shift}.start_with?("ac")
      expect(enumerator.next).to eq("ac")
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'selects the elements that match several predicates' do
      values = ["ab", "ac", "bb", "bc"]
      enumerator = doing{values.shift}.start_with?("b").end_with?("b")
      expect(enumerator.next).to eq("bb")
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'maps the elements with a method that is not a predicate' do
      values = [1, 2]
      enumerator = doing{values.shift}.succ
      expect(enumerator.next).to eq(2)
      expect(enumerator.next).to eq(3)
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'maps the elements with several methods that are not predicates' do
      values = [1, 2]
      enumerator = doing{values.shift}.succ.succ
      expect(enumerator.next).to eq(3)
      expect(enumerator.next).to eq(4)
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'chaining an undefined method will asume is defined in Kernel' do
      values = ["value"]
      enumerator = doing{values.shift}.global_method
      expect(enumerator.next).to eq("global method result for value")
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    def Kernel.global_method(argument)
      "global method result for #{argument}"
    end
  end
end
