require 'doing'

RSpec.describe Doing do
  include Doing

  describe 'doing' do
    it 'raises error when no block is given' do
      expect{doing}.to raise_error(ArgumentError, 'No block given')
    end

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

    it 'can take up to n elements' do
      values = [1, 2, 3, 4]
      enumerator = doing{values.shift}.take(1)
      expect(enumerator.next).to eq(1)
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'returns fluent enumerator after taking n elements' do
      enumerator = doing{rand}
      expect(enumerator.take(0).class).to eq(enumerator.class)
    end

    it 'can take elements while a predicate dictates' do
      values = [1, 2, 3, 4]
      enumerator = doing{values.shift}.take_while{|v| v < 3}
      expect(enumerator.next).to eq(1)
      expect(enumerator.next).to eq(2)
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'returns fluent enumerator after take_while' do
      enumerator = doing{rand}
      expect(enumerator.take_while{false}.class).to eq(enumerator.class)
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
      enumerator = doing{values.shift}.map{|v| acc += v}
      expect(acc).to eq(0)
      returned_after_each = enumerator.each
      expect(acc).to eq(10)
      expect(returned_after_each).to be(nil)
    end

    it 'injects each element into an accumulator' do
      values = [1, 2, 3, 4]
      result = doing{values.shift}.inject(:+)
      expect(result).to eq(10)
    end

    class ElementPredicateSpy
      attr_reader :result, :received_args, :received_block

      def initialize(result)
        @result = result
      end

      def predicate?(*args, &block)
        @received_args = args
        @received_block = block

        result
      end

      def predicate_without_question_mark(*args, &block)
        predicate?(*args, &block)
      end
    end

    it 'selects the elements that match a predicate finished in ?' do
      selected_element = ElementPredicateSpy.new(true)
      unselected_element = ElementPredicateSpy.new(false)
      values = [unselected_element, selected_element]
      block = Proc.new{}

      enumerator = doing{values.shift}.predicate?("argument", &block)

      expect(enumerator.next).to be(selected_element)
      expect{enumerator.next}.to raise_error(StopIteration)
      expect(unselected_element.received_args).to eq(["argument"])
      expect(unselected_element.received_block).to be(block)
      expect(selected_element.received_args).to eq(["argument"])
      expect(selected_element.received_block).to be(block)
    end

    it 'selects the elements that match a predicate not finished in ?' do
      selected_element = ElementPredicateSpy.new(true)
      unselected_element = ElementPredicateSpy.new(false)
      values = [unselected_element, selected_element]
      block = Proc.new{}

      enumerator = doing{values.shift}.predicate_without_question_mark?("argument", &block)

      expect(enumerator.next).to be(selected_element)
      expect{enumerator.next}.to raise_error(StopIteration)
      expect(unselected_element.received_args).to eq(["argument"])
      expect(unselected_element.received_block).to be(block)
      expect(selected_element.received_args).to eq(["argument"])
      expect(selected_element.received_block).to be(block)
    end

    it 'selects the elements that match several predicates' do
      values = ["ab", "ac", "bb", "bc"]
      words = doing{values.shift}
      enumerator = words.start_with?("b").end_with?("b")

      expect(enumerator.next).to eq("bb")
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    it 'forwards the include? predicate as a selection of the elements' do
      values = ["ab", "ac", "bb", "bc"]
      enumerator = doing{values.shift}.include?("a")
      expect(enumerator.next).to eq("ab")
      expect(enumerator.next).to eq("ac")
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    class ElementTransformationSpy
      attr_reader :result, :received_args, :received_block

      def initialize(result)
        @result = result
      end

      def transform(*args, &block)
        @received_args = args
        @received_block = block

        result
      end
    end

    it 'maps the elements with a method that is not a predicate' do
      transforms_to_1_element = ElementTransformationSpy.new(1)
      transforms_to_2_element = ElementTransformationSpy.new(2)
      values = [transforms_to_1_element, transforms_to_2_element]
      block = Proc.new{}

      enumerator = doing{values.shift}.transform("argument", &block)

      expect(enumerator.next).to eq(1)
      expect(enumerator.next).to eq(2)
      expect{enumerator.next}.to raise_error(StopIteration)
      expect(transforms_to_1_element.received_args).to eq(["argument"])
      expect(transforms_to_1_element.received_block).to be(block)
      expect(transforms_to_2_element.received_args).to eq(["argument"])
      expect(transforms_to_2_element.received_block).to be(block)
    end

    it 'maps the elements with several methods that are not predicates' do
      values = [1, 2]
      enumerator = doing{values.shift}.succ.succ
      expect(enumerator.next).to eq(3)
      expect(enumerator.next).to eq(4)
      expect{enumerator.next}.to raise_error(StopIteration)
    end

    def Kernel.global_method(*args, &block)
      "global method result for #{args.inspect} using #{yield 'content'}"
    end

    it 'chaining an undefined method will asume is defined in Kernel' do
      values = ["value1", "value2"]
      enumerator = doing{values.shift}.global_method("argument1"){|v|"block_"+v}
      expect(enumerator.next).to eq('global method result for ["value1", "argument1"] using block_content')
      expect(enumerator.next).to eq('global method result for ["value2", "argument1"] using block_content')
      expect{enumerator.next}.to raise_error(StopIteration)
    end
  end
end
