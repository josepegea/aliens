module Aliens
  class Matcher
    def match(pattern, reading)
      diff = diff_maps(pattern, reading)
      grade_diff(diff, pattern)
    end

    private

    def diff_maps(pattern, reading)
      diff = 0
      pattern.each_y.map do |y|
        pattern.each_x.map do |x|
          diff += (pattern.tick_at(x, y) - reading.tick_at(x, y)).abs
        end
      end
      diff
    end

    def grade_diff(diff, pattern)
      total_ticks = pattern.x_size * pattern.y_size
      1.0 - (diff.to_f / total_ticks.to_f)
    end
  end
end
