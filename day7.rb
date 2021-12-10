require 'pry'

class Day7
  def initialize(input = [16,1,2,0,4,2,7,1,2,14])
    @input    = input
    @min_fuel = nil
    @shortest = nil
  end
  
  def solve
    positions_range.each do |converge_point|
      fuel_usage = @input.each_with_object([]) do |position, arr|        
        arr << trip_fuel(converge_point, position)
      end.sum
      add_min_fuel! fuel_usage
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
# d = Day7.new
# d.solve
# binding.pry

