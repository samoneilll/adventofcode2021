class DayFive
  VERTICAL   = 'vertical'.freeze
  HORIZONTAL = 'horizontal'.freeze
  DIAGONAL   = 'diagonal'.freeze

  def initialize(file)
    @file = file
  end
  
  def solve(diagonals = true)    
    reject_diagonals! unless diagonals # filter diagonal lines and remove them from the array of lines unless called with solve(false)
    map_lines.filter { |k,v| v > 1 }.size # map points lines cross and filter for only points with more than one hit
  end

  private
  
  ###
  # Memoized helper function to parse input file into an array of line arrays:
  # [
  #  [[0,8],[2,8]],
  #  [[2,6],[4,0]]
  # ]
  # `@lines ||=` is memoized assignment so we can just call lines() anywhere in the class and if it's not assigned it 
  # assigns and returns the value, if already assigned it just returns the value.
  # it's a gross one-liner, but it's parsing input so who cares.
  ###
  def lines
    @lines ||= File.readlines(@file).map { |line| line.strip.split(/\ ->\ /).map {|part| part.split(',').map {|i| i.to_i }}}
  end


  ###
  # loop over each line and map the points the line passes through into a an object
  # if we have lines [ [[0,2],[0,4]], and [[0,3],[0,4]] then this would map to:
  # {
  #   "0-02": 1,
  #   "0-03": 2,
  #   "0-04": 2
  # }
  ###
  def map_lines
    # loop for lines with object "points" available inside the block as the object we're mapping to object keys defaulting to 0
    lines.each_with_object( Hash.new {|h,k| k = 0} ) do |line, points|
      direction = line_direction line # determine the line direction ("horizontal" || "vertical" || "diagonal")

      # line_points() returns an array of the points the line passes through, for example:
      #   `line_points([[0,2],[2,4]], "diagonal") => [[0, 2], [1, 3], [2, 4]]`
      # 
      # When then loop over each of these points and then add this key to the points object and iterate its value by 1
      #
      # i.e if our points are [[0,2],[1,3]] we join each array to a string and do: 
      #   points[ "0-2" ] += 1
      #   points[ "1-3" ] += 1
      # 
      # Because we set the default key value to 0, we don't need to check if the key exists in the object first before doing the ++
      line_points(line, direction).each do |point|
        points[ point.join('-') ] += 1
      end
    end
  end


  ###
  # return an array of points the line passes through.
  # we do this by first sorting the start and end point for each axis and create a range
  #   line: [[0,2],[0,4]] => ranges: x = (0..0) and y = (2..4)

  # we then convert this range to an array:
  #   ranges: x = (0..0) and y = (2..4) => arrays: x = [0] and y = [2,3,4]
  # 
  # we then map a new 3d array by "zipping" the two arrays:
  #   arrays: x = [0] and y = [2,3,4] => zipped array: [[0,2],[0,3],[0,4]]
  # 
  # In order to create the range we had to sort the x/y values, 
  # i.e if we have the line ([3,0],[1,0]) we cannot create the range (3..1) 
  # because ruby ranges must move in a positive direction.
  # for horizontal/vertical lines this doesn't matter, but for diagonal lines we need to restore the 
  # correct order before zipping the ranges together
  ###
  def line_points(line, direction)
    x       = [line[0][0], line[1][0]].sort # line [[0,4][0,2]] => [0,0]
    y       = [line[0][1], line[1][1]].sort # line [[0,4][0,2]] => [2,4]
    x_range = (x[0]..x[1]).to_a # [0,0] => (0..0) => [0]
    y_range = (y[0]..y[1]).to_a # [2,4] => (2..4) => [2,3,4]

    # arrays need to be the same size to zip correctly, so for horizontal/vertical lines we need to map the stationary axis array 
    # to new array to match the size of the other axis
    # so in our case we are dealing with a vertical line and we do the following: 
    #   [2,3,4].map { 0 } => [0,0,0]
    #   [0,0,0].zip( [2,3,4] ) => [ [0,2], [0,3], [0,4] ] << this is our return array.
    return x_range.zip(x_range.map{ y[1] }) if direction == HORIZONTAL
    return y_range.map{ x[0] }.zip y_range if direction == VERTICAL


    # consider the line [4,2][2,4], we would have mapped this to the arrays x_range = [2,3,4] and y_range = [2,3,4] after sorting
    # and if we zip we then get [2,2],[3,3],[4,4], so before we zip diagonals we have to check the positions in the original line 
    # and reverse if they're not correct
    #   x_range = [2,3,4] but line[0][0] == 4 > line[1][0] == 2 so we reverse the array
    x_range.reverse! if line[0][0] > line[1][0] 
    y_range.reverse! if line[0][1] > line[1][1]

    x_range.zip(y_range)
  end


  ###
  # simple helper function to filter and remove diagonal lines for part 1
  ###
  def reject_diagonals!
    lines.reject! { |line| line_direction(line) == DIAGONAL }
  end

  ###
  # helper function to return line direction
  ### 
  def line_direction(line)    
    return HORIZONTAL if line[0][1] == line[1][1]
    return VERTICAL   if line[0][0] == line[1][0]
    DIAGONAL
  end  
end

puts "part 1: #{DayFive.new('./input.txt').solve(false)}"
puts "part 2: #{DayFive.new('./input.txt').solve}"