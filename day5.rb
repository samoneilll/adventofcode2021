class DayFive
  VERTICAL   = 'vertical'.freeze
  HORIZONTAL = 'horizontal'.freeze
  DIAGONAL   = 'diagonal'.freeze

  def initialize(file)
    @file = file
  end

  def solve(diagonals = true)    
    reject_diagonals! unless diagonals
    map_lines.filter { |k,v| v > 1 }.size    
  end

  private
  
  def lines
    @lines ||= File.readlines(@file).map { |line| line.strip.split(/\ ->\ /).map {|part| part.split(',').map {|i| i.to_i }}}
  end

  def map_lines
    lines.each_with_object( Hash.new {|h,k| k = 0} ) do |line, points|
      direction = line_direction line
      line_points(line, direction).each do |point|
        points[ point.join('-') ] += 1
      end
    end
  end

  def line_points(line, direction)
    x       = [line[0][0], line[1][0]].sort
    y       = [line[0][1], line[1][1]].sort
    x_range = (x[0]..x[1]).to_a
    y_range = (y[0]..y[1]).to_a

    return x_range.zip(x_range.map{y[1]}) if direction == HORIZONTAL
    return y_range.map{x[0]}.zip y_range if direction == VERTICAL

    x_range.reverse! if line[0][0] > line[1][0]
    y_range.reverse! if line[0][1] > line[1][1]

    x_range.zip(y_range)
  end

  def reject_diagonals!
    lines.reject! { |line| line_direction(line) == DIAGONAL }
  end

  def line_direction(line)    
    return HORIZONTAL if line[0][1] == line[1][1]
    return VERTICAL   if line[0][0] == line[1][0]
    DIAGONAL
  end  
end

puts "part 1: #{DayFive.new('./inputs/day5.txt').solve(false)}"
puts "part 2: #{DayFive.new('./inputs/day5.txt').solve(true)}"