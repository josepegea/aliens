# frozen_string_literal: true

module Aliens
  # Common functionality for every TickMap
  #
  # This module is already mixed in AbstractTickMap
  #
  # If you implement a custom TickMap that doesn't inherit from that,
  # you can mix in this module to get this functionality, too
  module TickMappable
    def to_s
      each_y.map do |y|
        each_x.map do |x|
          tick_at(x, y) == 1 ? 'o' : '-'
        end.join('')
      end.join("\n")
    end

    def each_x
      x_size.times
    end

    def each_y
      y_size.times
    end
  end
end
