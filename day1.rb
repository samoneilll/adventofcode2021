class DayTwo
  attr_reader :movements

  def initialize
    @input = File.readlines('./inputs/day1.txt').map {|l| l.strip.to_i}
  end

  def solve
    @movements = []
    previous = nil
    map_windows(@input).each do |value|
      previous = compare_values(value, previous)
    end
    @movements.tally['increased']
  end

  def map_windows(arr)
    windows = []
    i = 0
    while i < arr.size do
      windows << arr[i..i+2].sum
      i += 1
    end
    windows
  end

  def compare_values(curr, prev)
    @movements << direction(curr, prev) if prev
    curr
  end

  def direction(cr,pr)
    cr > pr ? "increased" : "decreased"
  end
end