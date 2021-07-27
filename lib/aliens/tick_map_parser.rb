module Aliens
  class TickMapParser
    attr_reader :tick_char, :empty_char
    attr_reader :tick_map_class

    def initialize(tick_char: 'o', empty_char: '-', tick_map_class: TickMap)
      @tick_char = tick_char
      @empty_char = empty_char
      @tick_map_class = tick_map_class
    end

    def parse(data)
      parse_lines(data)
    end

    private

    def parse_lines(data, tick_map: tick_map_class.new)
      data.each_line(chomp: true) do |line|
        tick_map.add_line(parse_line(line))
      end
      tick_map
    end

    def parse_line(line)
      line.each_char.map do |char|
        case char
        when tick_char
          1
        when empty_char
          0
        else
          # This is noise. Let's treat it as so
          rand.round
        end
      end
    end
  end
end
