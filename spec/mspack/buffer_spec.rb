require 'spec_helper'

module Mspack
  describe Buffer do

    describe '#[buffer_range]' do
      it 'accepts a BufferRange and returns a sub-array' do
        range = BufferRange.new(4, 2..1)
        buffer = Buffer.new([ 0, 1, 2, 3, 4 ])
        expect(buffer[range]).to eq([ 2, 3, 4, 0, 1 ])
      end
    end

    describe '#[buffer_range]=(data)' do
      it 'raises an exception if data#length exceeds buffer_range#length' do
        range = BufferRange.new(4, 1..2)
        buffer = Buffer.new([ 1, 2, 3, 4 ])
        expect {
          buffer[range] = [ 9, 8, 7, 8, 9 ]
        }.to raise_error(ArgumentError)
      end

      it 'accepts a BufferRange and assigns the data' do
        range = BufferRange.new(5, 0..2)
        buffer = Buffer.new([ 1, 2, 3, 4 ])
        buffer[range] = [ 9, 22, 833 ]
        expect(buffer).to eq([ 9, 22, 833, 4 ])
      end
    end
  end
end
