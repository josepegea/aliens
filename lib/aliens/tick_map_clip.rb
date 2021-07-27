require_relative 'abstract_tick_map'

module Aliens
  class TickMapClip < AbstractTickMap
    attr_reader :x_start
    attr_reader :y_start
    attr_reader :x_size
    attr_reader :y_size

    def initialize(original_clip, x_start, y_start, x_size, y_size)
      @original_clip = original_clip
      @x_start = x_start
      @y_start = y_start
      @x_size = x_size
      @y_size = y_size
    end

    def tick_at(x, y = 0)
      @original_clip.tick_at(x_start + x, y_start + y)
    end
  end
end
