require 'spec_helper'

module Mspack
  describe BufferRange do

    describe '#new' do
      it 'accepts a max value and a range' do
        range = BufferRange.new(9, 1..5)
        expect(range.max).to eq(9)
        expect(range).to eq(1..5)
      end

      it 'raises an error if the range end is greater than max' do
        expect { BufferRange.new(7, 5..7) }.not_to raise_error
        expect { BufferRange.new(5, 1..6) }.to raise_error(ArgumentError)
      end
    end

    describe '#+' do
      it 'advances both #begin and #end by the num parameter' do
        range = BufferRange.new(2_048, 0..83)
        range += 52
        expect(range.max).to eq(2_048)
        expect(range).to eq(52..135)
      end

      it "swings back around if advanced beyond #max (hint: it's 0 based)" do
        range = BufferRange.new(8, 0..3)
        range += 6
        expect(range.max).to eq(8)
        expect(range).to eq(6..0)
      end
    end

    describe '#length' do
      it 'returns the range length' do
        range = BufferRange.new(8, 0..5)
        expect(range.length).to eq(6)
      end

      it 'loops back around when counting the length if it includes #max' do
        range = BufferRange.new(9, 8..1)
        expect(range.length).to eq(4)
      end
    end

    describe '#-' do
      it 'decrements both #begin and #end by the num parameter' do
        range = BufferRange.new(8, 6..8)
        range -= 2
        expect(range).to eq(4..6)
      end

      it "swings back around if advanced beyond #max (hint: it's 0 based)" do
        range = BufferRange.new(4, 3..1)
        range -= 3
        expect(range).to eq(0..3)
      end
    end

    describe '#zero' do
      it 'moves the range to start at 0' do
        range = BufferRange.new(5, 5..2)
        expect(range.zero).to eq(0..3)
      end
    end
  end
end
