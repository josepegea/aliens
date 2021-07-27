# frozen_string_literal: true

require_relative 'tick_mappable'

module Aliens
  # Basic interface for every TickMap
  # The rest of the classes (except the parser) use only these methods
  class AbstractTickMap
    include TickMappable

    def tick_at(x, y = 0)
      raise NotImplementedError
    end

    def x_size
      raise NotImplementedError
    end

    def y_size
      raise NotImplementedError
    end
  end
end
