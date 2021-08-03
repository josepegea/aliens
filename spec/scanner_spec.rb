# frozen_string_literal: true

require 'spec_helper'

# Clipper subclass that keeps track of scanned ticks
class TracedClipper < Aliens::Clipper
  attr_reader :traced_tick_map
  attr_accessor :tick_hits

  # rubocop:disable Lint/MissingSuper
  def initialize(traced_tick_map)
    @traced_tick_map = traced_tick_map
    @tick_hits = traced_tick_map.y_size.times.map { Array.new(traced_tick_map.x_size, 0) }
  end
  # rubocop:enable Lint/MissingSuper

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
      scanner.scan(reading)
      expect(traced_clipper.tick_hits.flatten.any? { |v| v == 0 }).to be false
    end
  end

  describe "edge cases" do
    let(:alien) do
      pattern = <<~TEXT
        ooooo
        o---o
        o---o
        o---o
        ooooo
      TEXT
      parser.parse(pattern)
    end

    let(:reading_no_partials) do
      pattern = <<~TEXT
        -------------------
        -------------------
        -------------------
        -------------------
        -------------------
        -------------------
        -------ooooo-------
        -------o---o-------
        -------o---o-------
        -------o---o-------
        -------ooooo-------
        -------------------
        -------------------
        -------------------
        -------------------
        -------------------
      TEXT
      parser.parse(pattern)
    end

    let(:reading_partials20) do
      pattern = <<~TEXT
        o--------ooooo----o
        -------------------
        -------------------
        -------------------
        ------------------o
        ------------------o
        o------ooooo------o
        o------o---o------o
        o------o---o------o
        o------o---o-------
        o------ooooo-------
        -------------------
        -------------------
        -------------------
        -------------------
        o-----------------o
      TEXT
      parser.parse(pattern)
    end

    let(:reading_partials40) do
      pattern = <<~TEXT
        -o-------o---o---o-
        oo-------ooooo---oo
        -------------------
        -------------------
        -----------------oo
        -----------------o-
        oo-----ooooo-----o-
        -o-----o---o-----o-
        -o-----o---o-----oo
        -o-----o---o-------
        oo-----ooooo-------
        -------------------
        -------------------
        -------------------
        oo---------------oo
        -o---------------o-
      TEXT
      parser.parse(pattern)
    end

    let(:reading_partials60) do
      pattern = <<~TEXT
        --o------o---o--o--
        --o------o---o--o--
        ooo------ooooo--ooo
        -------------------
        ----------------ooo
        ----------------o--
        ooo----ooooo----o--
        --o----o---o----o--
        --o----o---o----ooo
        --o----o---o-------
        ooo----ooooo-------
        -------------------
        -------------------
        ooo-------------ooo
        --o-------------o--
        --o-------------o--
      TEXT
      parser.parse(pattern)
    end

    let(:reading_partials80) do
      pattern = <<~TEXT
        ---o-----o---o-o---
        ---o-----o---o-o---
        ---o-----o---o-o---
        oooo-----ooooo-oooo
        ---------------oooo
        ---------------o---
        oooo---ooooo---o---
        ---o---o---o---o---
        ---o---o---o---oooo
        ---o---o---o-------
        oooo---ooooo-------
        -------------------
        oooo-----------oooo
        ---o-----------o---
        ---o-----------o---
        ---o-----------o---
      TEXT
      parser.parse(pattern)
    end

    context "with default edge thereshold" do
      let(:scanner) { Aliens::Scanner.new([alien], minimum_confidence_factor: 1) }

      it "works with no edge cases" do
        expect(scanner.scan(reading_no_partials).size).to eq(1)
      end

      it "works with edge cases well below thereshold" do
        expect(scanner.scan(reading_partials20).size).to eq(1)
      end

      it "works with edge cases just below thereshold" do
        expect(scanner.scan(reading_partials40).size).to eq(1)
      end

      it "works with edge cases just above thereshold" do
        expect(scanner.scan(reading_partials60).size).to eq(8)
      end

      it "works with edge cases well above thereshold" do
        expect(scanner.scan(reading_partials80).size).to eq(8)
      end
    end

    context "with 20% edge thereshold" do
      let(:scanner) do
        Aliens::Scanner.new([alien],
                            edge_thereshold: 0.2,
                            minimum_confidence_factor: 1)
      end

      it "works with no edge cases" do
        expect(scanner.scan(reading_no_partials).size).to eq(1)
      end

      it "works with edge cases exactly on thereshold" do
        expect(scanner.scan(reading_partials20).size).to eq(8)
      end

      it "works with edge cases just above thereshold" do
        expect(scanner.scan(reading_partials40).size).to eq(8)
      end

      it "works with edge cases well above thereshold" do
        expect(scanner.scan(reading_partials60).size).to eq(8)
      end

      it "works with edge cases far above thereshold" do
        expect(scanner.scan(reading_partials80).size).to eq(8)
      end
    end

    context "with 40% edge thereshold" do
      let(:scanner) do
        Aliens::Scanner.new([alien],
                            edge_thereshold: 0.4,
                            minimum_confidence_factor: 1)
      end

      it "works with no edge cases" do
        expect(scanner.scan(reading_no_partials).size).to eq(1)
      end

      it "works with edge cases below thereshold" do
        expect(scanner.scan(reading_partials20).size).to eq(1)
      end

      it "works with edge cases exactly on thereshold" do
        expect(scanner.scan(reading_partials40).size).to eq(8)
      end

      it "works with edge cases just above thereshold" do
        expect(scanner.scan(reading_partials60).size).to eq(8)
      end

      it "works with edge cases well above thereshold" do
        expect(scanner.scan(reading_partials80).size).to eq(8)
      end
    end

    context "with 60% edge thereshold" do
      let(:scanner) do
        Aliens::Scanner.new([alien],
                            edge_thereshold: 0.6,
                            minimum_confidence_factor: 1)
      end

      it "works with no edge cases" do
        expect(scanner.scan(reading_no_partials).size).to eq(1)
      end

      it "works with edge cases far below thereshold" do
        expect(scanner.scan(reading_partials20).size).to eq(1)
      end

      it "works with edge cases just below thereshold" do
        expect(scanner.scan(reading_partials40).size).to eq(1)
      end

      it "works with edge cases exactly on thereshold" do
        expect(scanner.scan(reading_partials60).size).to eq(8)
      end

      it "works with edge cases just above thereshold" do
        expect(scanner.scan(reading_partials80).size).to eq(8)
      end
    end

    context "with 80% edge thereshold" do
      let(:scanner) do
        Aliens::Scanner.new([alien],
                            edge_thereshold: 0.8,
                            minimum_confidence_factor: 1)
      end

      it "works with no edge cases" do
        expect(scanner.scan(reading_no_partials).size).to eq(1)
      end

      it "works with edge cases far below thereshold" do
        expect(scanner.scan(reading_partials20).size).to eq(1)
      end

      it "works with edge cases well below thereshold" do
        expect(scanner.scan(reading_partials40).size).to eq(1)
      end

      it "works with edge cases just below thereshold" do
        expect(scanner.scan(reading_partials60).size).to eq(1)
      end

      it "works with edge cases exactly on thereshold" do
        expect(scanner.scan(reading_partials80).size).to eq(8)
      end
    end

    context "with no edge thereshold" do
      let(:scanner) do
        Aliens::Scanner.new([alien],
                            edge_thereshold: 1.0,
                            minimum_confidence_factor: 1)
      end

      it "works with no edge cases" do
        expect(scanner.scan(reading_no_partials).size).to eq(1)
      end

      it "works with edge cases below thereshold" do
        expect(scanner.scan(reading_partials20).size).to eq(1)
      end

      it "works with edge cases below thereshold" do
        expect(scanner.scan(reading_partials40).size).to eq(1)
      end

      it "works with edge cases below thereshold" do
        expect(scanner.scan(reading_partials60).size).to eq(1)
      end

      it "works with edge cases below thereshold" do
        expect(scanner.scan(reading_partials80).size).to eq(1)
      end
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
