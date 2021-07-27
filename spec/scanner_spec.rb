require 'spec_helper'

# Clipper subclass that keeps track of scanned ticks
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

  describe "collecting positives" do
    let(:dumb_matcher) { Aliens::Matcher.new }
    let(:scanner) { Aliens::Scanner.new([alien], matcher: dumb_matcher) }
    let(:responses) { [0, 0, 0.5, 0.9, 0.8, 0.2, 0.7, 0.85, 0] }

    before do
      allow(dumb_matcher).to receive(:match).and_return(*responses)
    end

    it "returns the matching aliens with default confidence factor" do
      results = scanner.scan(reading)
      expect(results.size).to eq(2)
      expect(results.map(&:confidence_factor)).to eq([0.9, 0.85])
    end

    it "returns the matching aliens with custom confidence factor" do
      scanner = Aliens::Scanner.new([alien],
                                    matcher: dumb_matcher,
                                    minimum_confidence_factor: 0.7)
      results = scanner.scan(reading)
      expect(results.size).to eq(4)
      expect(results.map(&:confidence_factor)).to eq([0.9, 0.8, 0.7, 0.85])
    end
  end
end
