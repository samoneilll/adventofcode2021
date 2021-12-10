
class DayThreePartTwo
  # declare class constant with ranges and values for deciding which value to use they're equal
  RANGES = {min: '0', max: '1'}

  # main logic, accepts input arg from outside the class, returns array with power and lifesupport values.
  def solve(input)
    # Take keys from RANGES constant and use them to map array from min/max
    # the `inject(:*)` is just shorthard for multiplying all elements in the array.
    # In JS it would be something like: 
    # ['min', 'max'].map ( range => parseInt( power_output_filter(input, range), 2 ).reduce( (x,y) => x * y )
    power_output = RANGES.keys.map { |range| power_output_filter(input, range.to_s).join('').to_i(2) }.inject(:*)
    life_support = RANGES.keys.map { |range| life_support_filter(input, range.to_s).to_i(2) }.inject(:*)
    [power_output, life_support]
  end

  def power_output_filter(values, range)
    # passes array of input values to tallies func which returns object like {0: {0: 5, 1: 7}, 1: {0: 2, 1: 10}....}
    # then it maps that object with select_byte func which finds min/max from individual byte counts like {0: 5, 1: 7} should
    # return 0 when range == min, or 1 when range == max.
    tallies(values).map { |_k, v| select_byte(range,v) }
  end

  def life_support_filter(values, range, pos = 0)
    # recursive function that accepts array ofinput values, range (min/max) and position, 
    # sets position to 0 if not included in args

    # if we've reduced the array to just one element, return that element
    return values[0] if values.size == 1

    # pass array of values to tallies func to get object with counts in each byte position
    t = tallies(values)

    # filter values array for only values where the char at position is the same as most/least common byte
    # I guess similar to JS values.filter ( r => r[0]) == select_byte('min', {0: 5, 1: 7}) )
    values = values.filter { |r| r[pos] == select_byte(range, t[pos])}

    # passes reduced array of values back into the function with position iterated
    life_support_filter(values, range, pos += 1)
  end

  def tallies(values)
    # maps object with tallies for each byte position

    # arr.each_with_object({}) instantiates a new object, and iterates over the array which the new object
    # available inside the loop. So, [1,2,3].each_with_with_object {|x, obj| obj[x] = x * 2} would eval to {1: 2, 2: 4, 3: 6}
    counts = values.each_with_object({}) do |value, obj|
      # split each string and iterate over as `v` with the index of it's position available as `i` inside the block
      # so "00101" => 
      # iteration 1: v = 0, i = 0
      # iteration 2: v = 0, i = 1
      # iteration 3: v = 1, i = 2
      value.split('').each_with_index do |v,i|
        # memoize instantiate empty array in the object if it doesn't exist. so if obj = {} and i = 0, we do obj[0] = []
        # but if obj == {0: []} we don't attempt to instantiate
        obj[i] ||= []

        # once we're sure array exists, concat the value. the << syntax is just like arr.push(val)
        obj[i] << v
      end
    end

    # takes counts object from previous block like {0: [1,1,1,0], 1: [0,1,1,1]} and reduces to {0: {0: 1, 1: 3}, 1: {0: 1, 1: 3}}
    # this is the return value, in ruby you don't need to declare `return` if is the last line, 
    # blocks always return the last thing they evaluated
    counts.each { |_k,v| counts[k] = v.tally }
  end

  def select_byte(range, tally)
    # decides which byte should be used based on min/max. So args might be like select_byte('max', {0: 5, 1: 7})

    # guard clause for equal counts on both 0 and 1, it uniqs the values and checks if size is 1, if so it returns value of the 
    # range key from the class constant at the top
    return RANGES[range.to_sym] if tally.values.uniq.size == 1

    # just standard ternary if statement, just returns the max/min by value from the object
    range == 'max' ? tally.max_by {|v| v[1]}[0] : tally.min_by {|v| v[1]}[0]
  end
end

# puts == "put string", so it creates new class instance, calls solve method with parsed input lines and gets back
# array like [3847100,4105235] and prints to terminal
puts DayThreePartTwo.new.solve(File.readlines('./inputs/day3.txt').map {|l| l.strip})