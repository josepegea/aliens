require 'spec_helper'

class TracedClipper < Aliens::Clipper
  attr_reader :traced_tick_map
  attr_accessor :tick_hits

  def initialize(traced_tick_map)
    @traced_tick_map = traced_tick_map
    @tick_hits = traced_tick_map.y_size.times.map { Array.new(traced_tick_map.x_size, 0) }
  end

  def clip(pattern, x_offset, y_offset, x_size, y_size)
    if pattern == traced_tick_map
      y_size.times do |y|
        x_size.times do |x|
          tick_hits[y_offset + y][x_offset + x] += 1
        end
      end
    end
    super
  end
end

describe Aliens::Scanner do
  let(:parser) { Aliens::TickMapParser.new }

  let(:reading) do
    pattern = <<~TEXT
      -----------
      -----------
      -----------
      -----------
      -----------
      -----------
      -----------
      -----------
    TEXT
    parser.parse(pattern)
  end

  let(:alien) do
    pattern = <<~TEXT
      ooooo
      ooooo
      ooooo
      ooooo
    TEXT
    parser.parse(pattern)
  end

  describe "scan coverage" do
    let(:traced_clipper) { TracedClipper.new(reading) }
    let(:scanner) { Aliens::Scanner.new([alien], clipper: traced_clipper) }

    it "scans all the ticks in the reading" do
      results = scanner.scan(reading)
      expect(traced_clipper.tick_hits.flatten.any? { |v| v == 0 }).to be false
    end
  end
end
