module Aliens
  class TickMapParser
    def initialize(tick_char: 'o', empty_char: '-', map_class: TickMap)
      @tick_char = tick_char
      @empty_char = empty_char
      @map_class = map_class
    end

    def parse(data)
      parse_lines(data)
    end

    private

    def parse_lines(data, map: @map_class.new)
      data.each_line(chomp: true).with_index do |line, idx|
        map.add_line(parse_line(line))
      end
      map
    end

    def parse_line(line)
      line.each_char.map do |char|
        case char
        when @tick_char
          1
        when @empty_char
          0
        else
          # This is noise. Let's treat it as so
          rand.round
        end
      end
    end
  end
end
