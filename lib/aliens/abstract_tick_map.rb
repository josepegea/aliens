module Aliens
  class AbstractTickMap
    def tick_at(x, y = 0)
      raise NotImplementedError
    end

    def x_size
      raise NotImplementedError
    end

    def y_size
      raise NotImplementedError
    end

    def to_s
      each_y.map do |y|
        each_x.map do |x|
          tick_at(x, y) == 1 ? 'o' : '-'
        end.join('')
      end.join("\n")
    end

    def each_x
      x_size.times.with_index
    end

    def each_y
      y_size.times.with_index
    end
  end
end
