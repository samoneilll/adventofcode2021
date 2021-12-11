class Day8
  def initialize(input)
    @input = map_input(input)
  end

  def solve
    @input.map { |signal_set| SignalSet.new(signal_set).decode_signals }.sum
  end

  def map_input(input_file)
    File.readlines(input_file).each_with_object([]) do |line,arr|
      parts = line.split(' | ')
      arr << {
        signals: parts[0].split(' '),
        output: parts[1].split(' ')
      }
    end
  end
end

class SignalSet
  def initialize(input)
    @segments        = {}
    @decoded_signals = {}
    @raw_signals     = input[:signals]
    @output          = input[:output]
  end

  def decode_signals
    unique_size_signals
    six_char_segments
    five_char_segments
    sort_decoded_signal_strings!
    decode_output_and_join
  end

  def decode_output_and_join
    @output.map { |signal| @decoded_signals.key(sort_signal(signal)) }.join('').to_i
  end

  def sort_decoded_signal_strings!
    @decoded_signals.each do |num , str|
      @decoded_signals[num] = sort_signal str
    end
  end

  def six_char_segments    
    six_chars = signals_by_size 6

    @decoded_signals[1].split('').each do |segment|
      six_chars.each do |signal|
        unless signal.include? segment
          @decoded_signals[6] = signal
          @segments[5] = @decoded_signals[1].delete segment          
        end
      end
    end
    six_chars.delete @decoded_signals[6]

    @decoded_signals[4].delete(@decoded_signals[1]).split('').each do |segment|
      six_chars.each do |signal|
        unless signal.include? segment
          @decoded_signals[0] = signal
          @segments[1] = @decoded_signals[4].delete(@decoded_signals[1] + segment)
        end
      end
    end
    six_chars.delete @decoded_signals[0]

    @decoded_signals[9] = six_chars[0]
  end

  def five_char_segments
    signals_by_size(5).each do |signal|
      unless signal.include? @segments[5]
        @decoded_signals[2] = signal
      else
        if signal.include? @segments[1]
          @decoded_signals[5] = signal
        else
          @decoded_signals[3] = signal
        end
      end
    end
  end

  def unique_size_signals
    @decoded_signals[1] = signals_by_size 2
    @decoded_signals[7] = signals_by_size 3
    @decoded_signals[4] = signals_by_size 4
    @decoded_signals[8] = signals_by_size 7
  end

  def signals_by_size(len)
    signals = @raw_signals.find_all { |sig| sig.size == len }
    signals.size > 1 ? signals : signals.first
  end

  def sort_signal(str)
    str.split('').sort.join('')
  end
end

puts Day8.new('./inputs/day8.txt').solve
