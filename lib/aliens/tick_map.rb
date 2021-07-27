# frozen_string_literal: true

require_relative 'abstract_tick_map'

module Aliens
  class AliensException < StandardError; end

  class NonRectangularError < AliensException; end

  class OutOfBoundsError < AliensException; end

  # Writable TickMap, the one created by TickMapParser
  class TickMap < AbstractTickMap
    attr_reader :x_size
    attr_reader :y_size

    # rubocop:disable Lint/MissingSuper
    def initialize(lines = nil)
      @lines = lines || []
      normalize
    end
    # rubocop:enable Lint/MissingSuper

    def tick_at(x, y = 0)
      check_bounds(x, y)
      @lines[y][x]
    end

    def add_line(line)
      @lines << line
      normalize
    end

    private

    def normalize
      @y_size = @lines.size
      @x_size = @lines&.first&.size || 0

      raise NonRectangularError unless @lines.all? { |line| line.size == @x_size }
    end

    def check_bounds(x, y)
      return unless x.negative? || y.negative? || x >= @x_size || y >= @y_size

      raise OutOfBoundsError, "Trying to access tick_at(#{x}, #{y}) with size #{x_size}:#{y_size}"
    end
  end
end
