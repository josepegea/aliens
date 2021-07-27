# frozen_string_literal: true

require_relative 'abstract_tick_map'

module Aliens
  # A TickMap that is a clipping of another one
  class TickMapClip < AbstractTickMap
    attr_reader :x_start
    attr_reader :y_start
    attr_reader :x_size
    attr_reader :y_size

    # rubocop:disable Lint/MissingSuper
    def initialize(original_clip, x_start, y_start, x_size, y_size)
      @original_clip = original_clip
      @x_start = x_start
      @y_start = y_start
      @x_size = x_size
      @y_size = y_size
    end
    # rubocop:enable Lint/MissingSuper

    def tick_at(x, y = 0)
      @original_clip.tick_at(x_start + x, y_start + y)
    end
  end
end
