###
# This is a bit shit, basically just brute force except for token attempt at 
# being smart by exiting early if we can see that the fuel cost is already 
# greater than the current minimum value. But it works.
###

class Day7
  def initialize(input = [16,1,2,0,4,2,7,1,2,14])
    @input    = input
    @min_fuel = nil
  end
  
  def solve
    positions_range.each do |converge_point|
      fuel_usage = @input.each_with_object([]) do |position, arr|
        arr << trip_fuel(converge_point, position)
        if @min_fuel
          break if arr.sum > @min_fuel
        end
      end
      add_min_fuel!(fuel_usage.sum) if fuel_usage
    end
    @min_fuel
  end

  def positions_range
    (@input.min..@input.max)
  end

  def trip_fuel(start, finish)
    distance = fuel((start - finish).abs)
  end

  def fuel(moves, total = 0, increment = 0)
    moves.times { total += (increment += 1) }
    total
  end

  def add_min_fuel!(fuel_usage)
    @min_fuel = fuel_usage if @min_fuel.nil?
    @min_fuel = fuel_usage if fuel_usage < @min_fuel
  end
end

puts Day7.new(File.read('./inputs/day7.txt').split(',').map(&:to_i)).solve
