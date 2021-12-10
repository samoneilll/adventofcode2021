class Day6
  def initialize(input: [], max_days: 0)
    @input    = input
    @max_days = max_days
    @spawning_fish = 0
  end

  def pass_time  
    spawn_initial_fish!
    @max_days.times { new_day! }
    @all_fish.map {|f| f.no_fish}.sum
  end

  def new_day!
    @spawning_fish = fish_by_timer(0).no_fish
    @all_fish.each do |fish|
      next_timer = fish_by_timer(fish.timer + 1)
      if next_timer
        fish.no_fish = next_timer.no_fish
      else
        fish.no_fish = 0
      end
    end
    reset_spawning_fish!
  end

  def spawn_initial_fish!
    @all_fish = (0..8).map do |timer|
      LanternFishState.new(timer: timer)
    end
    @input.each do |input|
      @all_fish.find { |fish| fish.timer == input }.no_fish += 1
    end
  end

  def reset_spawning_fish!
    fish_by_timer(8).no_fish =  @spawning_fish
    fish_by_timer(6).no_fish += @spawning_fish
  end

  def fish_by_timer(timer)
    @all_fish.find { |f| f.timer == timer }
  end
end

class LanternFishState
  attr_accessor :no_fish
  attr_reader :timer

  def initialize(timer: 8, no_fish: 0)
    @timer = timer
    @no_fish = 0
  end  
end


puts Day6.new(input: File.read('./input.txt').strip.split(',').map(&:to_i), max_days: 256).pass_time