require 'pry'

class InputParser
  def self.parse(lines)
    @numbers      = lines.shift.strip.split(',')
    current_board = []

    @boards = lines.each_with_object([]) do |line, boards|
      if line.strip.empty?
        boards << current_board unless current_board.empty?
        current_board = []
      else
        current_board << line.strip.gsub(/\ +/, ',').split(',')
      end
    end
    {numbers: @numbers, boards: @boards}
  end
end

class DayFour
  XD         = 'x'.freeze
  CONDITIONS = %w(win lose).freeze

  def solve(data)    
    CONDITIONS.map do |condition| 
      [condition, " result: ", multiply_results( mark_numbers(data, condition) )].join('')
    end
  end

  private

  def mark_numbers(data, condition)
    data[:numbers].each_with_index do |num, num_index|
      data[:boards].each do |board|

        columns = board.each_with_object(Hash.new {|h,k| h[k] = []}) do |row, col|
          next if board[0] == XD
          row.each_with_index do |value,col_index|
            mark_value!(value, num)
            if row.uniq == [XD]
              return [num.to_i, board] if win_condition?(condition, num_index, data)
              board.unshift XD
            end
            col[col_index] << value
          end
        end
        if column_solution?(columns)
          return [ num.to_i ,board ] if win_condition?(condition, num_index, data)         
          board.unshift XD
        end

      end      
      trim_solved_boards!(data) if condition == CONDITIONS[1]
    end
  end

  def multiply_results(results_arr)
    board_sum = 0
    results_arr[1].each do |row|
      row.each do |value|
        board_sum += value.to_i unless value == XD
      end
    end
    board_sum * results_arr[0]
  end

  ### HELPERS ###

  def mark_value!(str, num)
    str.gsub!(/^#{num}$/, XD) 
  end

  def win_condition?(condition, num_index, data)
    condition == CONDITIONS[0] || num_index + 1 == data[:numbers].size || data[:boards].size == 1 ? true : false
  end

  def column_solution?(columns)
    columns.map { |_k, v| v.uniq == [XD]}.include? true
  end

  def trim_solved_boards!(data)
    data[:boards].reject! { |board| board.first == XD }
  end
end

puts DayFour.new.solve( InputParser.parse(File.readlines('input.txt')) )