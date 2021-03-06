# frozen_string_literal: true

require_relative 'tick_map_clip'

module Aliens
  # Creates a clipped TickMap
  class Clipper
    def clip(tick_map, x, y, x_size, y_size)
      TickMapClip.new(tick_map, x, y, x_size, y_size)
    end
  end
end
