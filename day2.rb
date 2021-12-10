@current_location = {horizontal: 0, depth: 0, aim: 0}
File.readlines('./inputs/day2.txt').map {|l| l.strip}.each do |command|
  direction,val =  command.split(' ')

  case direction
  when 'forward'
    @current_location[:horizontal] += val.to_i
    @current_location[:depth] += val.to_i * @current_location[:aim]
  when 'up'
    @current_location[:aim] -= val.to_i
  when 'down'
    @current_location[:aim] += val.to_i
  end
end
puts @current_location[:depth] * @current_location[:horizontal]