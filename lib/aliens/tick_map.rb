module Aliens
  class NonRectangularScanError < StandardError; end
  class UnrecognizedCharInScanError < StandardError; end
  class OutOfBoundsError < StandardError; end

  class TickMap
    attr_reader :x_size
    attr_reader :y_size

    def initialize(data, tick_char: 'o', empty_char: '-')
      @lines = []
      @tick_char = tick_char
      @empty_char = empty_char
      parse_lines(data)
    end

    def tick?(x, y = 0)
      check_bounds(x, y)
      @lines[y][x]
    end

    private

    def parse_lines(data)
      data.lines(chomp: true).each_with_index do |line, idx|
        @lines[idx] = parse_line(line)
      end
      @y_size = @lines.size
      @x_size = @lines&.first&.size || 0
      raise NonRectangularScanError unless @lines.all? { |line| line.size == @x_size }
    end

    def parse_line(line)
      line.each_char.map do |char|
        case char
        when @tick_char
          true
        when @empty_char
          false
        else
          raise UnrecognizedCharInScanError
        end
      end
    end

    def check_bounds(x, y)
      raise OutOfBoundsError if x < 0 || y < 0 || x >= @x_size || y >= @y_size
    end
  end
end
