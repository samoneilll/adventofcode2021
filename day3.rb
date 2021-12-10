class DayThreePartTwo
  RANGES = {min: '0', max: '1'}

  def solve(input)
    power_output = RANGES.keys.map { |range| power_output_filter(input, range.to_s).join('').to_i(2) }.inject(:*)
    life_support = RANGES.keys.map { |range| life_support_filter(input, range.to_s).to_i(2) }.inject(:*)
    [power_output, life_support]
  end

  def power_output_filter(values, range)
    tallies(values).map { |_k, v| select_byte(range,v) }
  end

  def life_support_filter(values, range, pos = 0)
    return values[0] if values.size == 1

    t = tallies(values)    
    values = values.filter { |r| r[pos] == select_byte(range, t[pos])}
    life_support_filter(values, range, pos += 1)
  end

  def tallies(values)
    counts = values.each_with_object({}) do |value, obj|
      value.split('').each_with_index do |v,i|
        obj[i] ||= []
        obj[i] << v
      end
    end
    counts.each { |k,v| counts[k] = v.tally }
  end

  def select_byte(range, tally)
    return RANGES[range.to_sym] if tally.values.uniq.size == 1
    range == 'max' ? tally.max_by {|v| v[1]}[0] : tally.min_by {|v| v[1]}[0]
  end
end

puts DayThreePartTwo.new.solve(File.readlines('./inputs/day3.txt').map {|l| l.strip})