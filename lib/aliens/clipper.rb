require_relative 'tick_map_clip'

module Aliens
  class Clipper
    def clip(tick_map, x, y, x_size, y_size)
      TickMapClip.new(tick_map, x, y, x_size, y_size)
    end
  end
end
