require 'pry'

### 
# Parse the input into an object like: 
# {
#   numbers: [1,2,3,4]
#   boards: [
#     [[1,2,3],[4,5,6],[7,8,9]],
#     [[9,8,7],[6,5,4],[3,2,1]]
#   ]
# }
# We create the array of boards by appending rows into a "current_board" array till we hit an empty line, 
# then dump it and reset.
###
class InputParser
  ###
  # @param array lines
  # returns object
  ###
  def self.parse(lines)
    # shift the first line off the array, strip trailing/leading whitespace and split
    @numbers      = lines.shift.strip.split(',')

    # create an empty array that we'll use to store the current "board"
    current_board = []

    # loop over the remaining lines with a new "boards" array where we'll push completed boards
    @boards = lines.each_with_object([]) do |line, boards|
      # if a line is empty we assume we've hit an empty line and can dump the board into the boards arr
      # `"\n".strip => ""` and `"".empty? => true`
      if line.strip.empty?
        # push current_board to boards unless it's empty (ie, line after initial numbers line is blank but we don't have a board yet)
        boards << current_board unless current_board.empty?
        # reset the curret_board arr
        current_board = []
      else
        # if the line is not empty, clean it up, split it into arr of numbers and add it to the current_board
        current_board << line.strip.gsub(/\ +/, ',').split(',')
      end
    end
    # return the object
    {numbers: @numbers, boards: @boards}
  end
end


###
# Class for solving the bingo problem. Has one public function "solve"
### 
class DayFour
  # creating a frozen constants for strings we'll use a lot for performance reasons
  XD         = 'x'.freeze
  CONDITIONS = %w(win lose).freeze


   ###
  # solve() takes object from InputParser, iterates for ['win', 'lose'] and calls mark_numbers() on the data, 
  # and then passes the results to multiply_results to get a number back and interpolate into results string
  # 
  # @param object{} data
  # returns Array (["win result: 1234", "lose result: 5678"])
  ###
  def solve(data)    
    CONDITIONS.map do |condition| 
      [condition, " result: ", multiply_results( mark_numbers(data, condition) )].join('')
    end
  end

  private # just means functions declared below the `private` statement are private and can only be called from within the class


  ###
  # Takes data object created in InputParser and marks off numbers on the boards one by one till we find the winner.
  #
  # First loop iterates over the numbers.
  # Second loop iterates over the boards
  # Third inner loop iterates over each row in the board
  # Fourth inner loop literates over each value in a row
  #
  # When a match is found in Fourth loop, the number in the row is replaced with an 'x'
  # We cannot use 0 because 0 is a valid cell value, and we cannot destroy it since we need to track vertical solutions
  # After the value has been marked, we then check if all values in the row are 'x' and return if true
  # After all values in fourth loop have been evaluated, we go back to third loop where we map all the vertical rows and attempt to return
  # 
  # When a solution is found it returns an array with the final number, and the winning board like:
  # [14, [[x,x,x][1,2,3][x,5,6]] ]
  #
  # @param Object{} data
  # returns Array [Int, Array]
  ###  
  def mark_numbers(data, condition)

    data[:numbers].each_with_index do |num, num_index| # FIRST LOOP for numbers

      data[:boards].each do |board| # SECOND LOOP for boards

        # create a new object "columns" and iterate over the rows in the board with the columns object as "col"
        # inner block `(Hash.new {..})` just means the col object will be a Hash with empty array as the default key value
        columns = board.each_with_object(Hash.new {|h,k| h[k] = []}) do |row, col| # THIRD LOOP for rows
          
          next if board[0] == XD # go next if this board has been marked as solved

          # iterate over values with their index so we know which column they are in to track vertical solutions
          row.each_with_index do |value,col_index| # FOURTH LOOP for values
            
            # attempt to substitute the value for 'x' with regex matching, no change is made if no regex match found
            mark_value!(value, num) # attempts substitution in mark_value!() helper func
            
            # if all values in the row are 'x'
            if row.uniq == [XD]
              # If win conditions are met, return the number and board
              # win condition is evaluated in win_condition?() predicate helper
              return [num.to_i, board] if win_condition?(condition, num_index, data)

              # if we are looking for losing solution and didn't return, mark this board as solved by placing 'x' at from of array
              # ie: board [[1,2,3],[x,x,x],[4,5,6]] ==> [x, [1,2,3],[x,x,x],[4,5,6]]
              board.unshift XD
            end

            # horizontal matching found no solution so now we add values to the columns object to check vertically
            col[col_index] << value  # push the value to the column array
          end # FOURTH LOOP END
        end # THIRD LOOP END

        # at this point we've looped over all the rows in the board and created a map of the vertical rows. 
        # ie: if board == [ [x,x,0], [1,x,3], [12,x,3] ]
        # then columns == {0: [x,1,12], 1: [x,x,x] 2: [0,3,3] }
        # 
        # then we reduce each array to only the uniq values and map if they equal ['x'] and return if the resulting array contains true
        # this logic is performed in the column_solution?() predicate helper and works like this:
        #
        # step 1 - uniq ==> [x,1,2],[x],[0,3]
        # step 2 - map if each array == [x] ==> [false, true, false]
        # step 3 - return if array contains true
        if column_solution?(columns)
          # If win conditions are met, return the number and board
          return [ num.to_i ,board ] if win_condition?(condition, num_index, data)         
          board.unshift XD # mark this board as solved and move on if looking for losing solution
        end

      end

      # After we've looped all boards for this number, filter the boards array and remove any that start with 'x'
      # removing boards is done in the trim_solved_boards!() function. The ! on the end of the func name
      # is just a warning that it is a destructive method that alters the data it works on.
      trim_solved_boards!(data) if condition == CONDITIONS[1]
    end # FIRST LOOP END

  end

  ###
  # Take array of final number and board found in mark_numbers and solve for final result
  # results_arr will be something like [14, [['x','x','x']['1','2','3']['x','5','6']] ]
  # we had to keep the numbers as strings to do regex matching, so now we have to remove the 'x' values, and convert back to ints
  #
  # @param Array results_arr
  # returns Number
  ###
  def multiply_results(results_arr)
    board_sum = 0 # start a counter
    results_arr[1].each do |row| # loop over the rows
      row.each do |value| # loop over each value
        board_sum += value.to_i unless value == XD # convert to int and add to counter unless it's 'x'
      end
    end
    board_sum * results_arr[0] # multiply counter with final number
  end

  ### HELPERS

  # mark values in place in the rows array by checking regex match for the number string and replacing with 'x' 
  def mark_value!(str, num)
    str.gsub!(/^#{num}$/, XD) 
  end

  # Preciate to check if all win conditions are met:
  # condition == 'win' OR it's the final number OR it's the last board left in the boards array
  def win_condition?(condition, num_index, data)
    condition == CONDITIONS[0] || num_index + 1 == data[:numbers].size || data[:boards].size == 1 ? true : false
  end

  # check for column solution by mapping to uniq, compare to 'x' and check if resulting arr includes true
  def column_solution?(columns)
    columns.map { |_k, v| v.uniq == [XD]}.include? true
  end

  # removed solved boards by filtering out boards with 'x' in first position
  def trim_solved_boards!(data)
    data[:boards].reject! { |board| board.first == XD }
  end
end

puts DayFour.new.solve( InputParser.parse(File.readlines('input.txt')) )