require 'mspack/buffer_range'

module Mspack
  class Buffer < Array

    def [](range)
      return super(range) if range.begin <= range.end

      sub_array = Buffer.new(length, 0)
      rollover = range.max - range.begin

      sub_array[0..rollover] = super(range.begin..range.max)
      sub_array[(rollover + 1)..range.length] = super(0..range.end)

      sub_array
    end

    def []=(range, data)
      return super(range, data) if range.is_a?(Fixnum) && data.is_a?(Fixnum)
      return super(range, data) if range.instance_of?(Range)

      if data.length > range.length
        raise ArgumentError, 'data#length exceeds range#length'
      end

      return super(range, data) if range.begin <= range.end

      super(range.begin..(length - 1), data[range.begin..data.max])
      super(0..range.end, data[0..range.end])
    end
  end
end
