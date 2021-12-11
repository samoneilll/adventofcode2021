require 'pry'

class Day8
  SEGMENTS = (0..6).map { |i| [i,nil] }.to_h
  SIGNALS  = (0..9).map { |i| [i,nil] }.to_h

  def initialize(input)
    @input = map_sample_input(input)
    # @input = map_input(input)
  end

  def solve
    @input.map { |signal_set| count_uniqs(signal_set) }.sum
  end

#       0000      If "ab"   then a and b could both be segments 2 or 5. 
#      1    2     To identify which is which we should find a 6 digit signal with only a or b
#      1    2     
#       3333      
#      4    5
#      4    5
#       6666

  def map_segments(signal_set)
    @segments = SEGMENTS.dup
    @signals  = SIGNALS.dup
    two_char_segments signal_set[:digits]
    three_char_segments signal_set[:digits]
    four_char_segments signal_set[:digits]
    five_char_segments signal_set[:digits]
    seven_char_segments signal_set[:digits]
    binding.pry
  end

  def two_char_segments(digits)
    @signals[1] = digits.find { |sig| sig.size == 2 }
    six_candidates = digits.find_all { |sig| sig.size == 6 }
    @signals[1].split('').each do |seg|
      six_candidates.each do |candidate|
        if !candidate.include? seg
          @signals[6]   = candidate if 
          @segments[2]  = seg
        end
      end
    end
    @segments[5] = @signals[1].delete @segments[2]    
  end

  def three_char_segments(digits)
    @signals[7]   = digits.find { |sig| sig.size == 3 }
    @segments[0]  = @signals[7].delete @signals[1]
  end

  def four_char_segments(digits)
    @signals[4] = digits.find { |sig| sig.size == 4 }
    zero_candidates = digits.find_all { |sig| sig.size == 6 }
    @signals[4].delete(@signals[1]).split('').each do |seg|
      zero_candidates.each do |candidate|
        if !candidate.include? seg
          @signals[0]   = candidate 
          @segments[3]  = seg
          @segments[1]  = @signals[4].delete(@signals[1] + seg)
          zero_candidates.delete candidate
          zero_candidates.delete @signals[6]
          @signals[9]   = zero_candidates.first
        end
      end
    end
  end

  def five_char_segments(digits)
    two_candidates = digits.find_all { |sig| sig.size == 5 }
    two_candidates.each do |candidate|
      if !candidate.include? @segments[5]
        @signals[2] = candidate 
      else        
        if candidate.include? @segments[1]
          @signals[5] = candidate
        else
          @signals[3] = candidate
        end
      end
    end
  end

  def seven_char_segments(digits)
    @signals[8] = digits.find { |sig| sig.size == 7 }
  end

  def map_uniques(signal_set)
    signal_set[:digits].map{ |sig| unique_signal(sig) }
  end

  ## returns:
  # {
  #   signal: 'ab', value: 1
  # }
  def unique_signal(signal)
    case signal.length
    when 2
      {signal: signal, value: 1}
    when 3
      {signal: signal, value: 7}
    when 4
      {signal: signal, value: 4}
    when 7
      {signal: signal, value: 8}
    end
  end



  ## returns:
  # [
  #   {
  #     :digits=>["be", "cfbegad", "cbdgef", "fgaecd", "cgeb", "fdcge", "agebfd", "fecdb", "fabcd", "edb"],
  #     :output=>["fdgacbe", "cefdb", "cefbgd", "gcbe"]
  #   }
  # ]
  def map_sample_input(input)
    input.each_with_object([]) do |line, arr|
      parts = line.split(' | ')
      arr << {
        digits: parts[0].split(' '),
        output: parts[1].split(' ')
      }
    end
  end

  def map_input(input_file)
    File.readlines(input_file).each_with_object([]) do |line,arr|
      parts = line.split(' | ')
      arr << {
        digits: parts[0].split(' '),
        output: parts[1].split(' ')
      }
    end

  end
end

single_input = ["acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"]

input = [
	"be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe",
	"edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc",
	"fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg",
	"fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb",
	"aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea",
	"fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb",
	"dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe",
	"bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef",
	"egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb",
	"gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce",
]

d = Day8.new(single_input)
signal_set = d.instance_variable_get(:@input)[0]
d.map_segments signal_set
binding.pry