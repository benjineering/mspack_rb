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
  end
end
