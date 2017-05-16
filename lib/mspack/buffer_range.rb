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

  def -(num)
    a = advance(self.begin, -num)
    b = advance(self.end, -num)
    BufferRange.new(@max, a..b)
  end

  def length
    return self.end - self.begin + 1 if self.end >= self.begin
    @max - self.begin + self.end + 2
  end

  def zero
    BufferRange.new(@max, 0..(length - 1))
  end

  private

  def advance(number, amount)
    # no change
    if amount == 0
      return number

    # positive
    elsif amount > 0
      advanced = number + amount
      return advanced if advanced <= @max
      return advanced - @max - 1

    # negative
    else
      advanced = number + amount
      return advanced if advanced >= 0
      return advanced + @max + 1
    end
  end
end
