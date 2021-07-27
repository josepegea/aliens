require_relative 'tick_mappable'

module Aliens
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
