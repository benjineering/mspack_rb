require 'mspack/buffer_range'

module Mspack
  class Buffer < Array

    def [](range)
      super(range) if range.begin <= range.end

      a = Buffer.new(length, 0)

      range_1 = range.begin..(length - 1)
      advanced_1 = 0..(range.length - range.begin - 1)
      a[advanced_1] = super(range_1)

      range_2 = 0..range.end
      advanced_2 = (range.length - range.begin)..range.end
      a[advanced_2] = super(range_2)

      a
    end

    def []=(range, data)
      super(range, data) if range.begin <= range.end

      range_length = 
      if range.begin <= range.end
        range.end - range.begin
      else
        range.max - range.begin - 1 + range.end
      end

      if data.length > range_length
        raise ArgumentError, 'data#length exceeds range length'
      end

      super(range.begin..(length - 1), data[range.begin..data.max])
      super(0..range.end, data[0..range.end])
    end
  end
end
