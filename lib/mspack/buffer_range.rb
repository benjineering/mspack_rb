class BufferRange < Range
  attr_reader :max

  def initialize(max, range)
    raise ArgumentError, 'range#end cannot exceed max' if range.end > max
    super(range.begin, range.end)
    @max = max
  end

  def +(num)
    a = advance(self.begin, num)
    b = advance(self.end, num)
    BufferRange.new(@max, a..b)
  end

  private

  def advance(number, amount)
    advanced = number + amount
    return advanced unless advanced > @max
    advanced - @max - 1 # - 1 because it's 0 based
  end
end
