require 'mspack/buffer_range'

module Mspack
  class Buffer < Array

    def [](range)
      return super(range) if range.begin <= range.end

      sub_array = Buffer.new(length, 0)
      advanced_1 = range.begin..(length - 1)
      zeroed = range.zero
      sub_array[zeroed] = super(advanced_1)

      if range.end > 0
        range_2 = Range.new(range.max, 0..range.end)
        advanced_2 = (range.length - range.begin)..range.end
        sub_array[range_2] = super(advanced_2)
      end

      sub_array
    end

    def []=(range, data)
      return super(range, data) if range.is_a?(Fixnum) && data.is_a?(Fixnum)

      if data.length > range.length
        raise ArgumentError, 'data#length exceeds range#length'
      end

      return super(range, data) if range.begin <= range.end

      super(range.begin..(length - 1), data[range.begin..data.max])
      super(0..range.end, data[0..range.end])
    end
  end
end
