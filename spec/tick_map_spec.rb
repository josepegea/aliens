require 'spec_helper'
require 'aliens'
require 'pry'

describe 'TickMap' do
  let(:parser) { Aliens::TickMapParser.new }

  let(:blank) { '' }

  let(:empty_line) { '------' }
    
  let(:bulls_eye) do
    <<~TEXT
       -----
       --o--
       -----
    TEXT
  end

  let(:irregular_map) do
    <<~TEXT
       -----
       ----
       -----
    TEXT
  end

  describe "gets correct sizes" do
    it "for a blank map" do
      map = parser.parse(blank)
      expect(map.x_size).to eq(0)
      expect(map.y_size).to eq(0)
    end

    it "for a single line map" do
      map = parser.parse(empty_line)
      expect(map.x_size).to eq(6)
      expect(map.y_size).to eq(1)
    end

    it "for a multiline map" do
      map = parser.parse(bulls_eye)
      expect(map.x_size).to eq(5)
      expect(map.y_size).to eq(3)
    end

    it "raises for an irregular map" do
      expect { map = parser.parse(irregular_map) }.to raise_error(Aliens::NonRectangularError)
    end
  end

  describe "accesses individual ticks" do
    it "for a single line map" do
      map = parser.parse(empty_line)
      expect(map.tick_at(0)).to eq(0)
      expect(map.tick_at(1)).to eq(0)
      expect(map.tick_at(5)).to eq(0)
      expect { map.tick_at(6) }.to raise_error(Aliens::OutOfBoundsError)
      expect { map.tick_at(0, 1) }.to raise_error(Aliens::OutOfBoundsError)
    end

    it "for a multiline map" do
      map = parser.parse(bulls_eye)
      expect(map.tick_at(0)).to eq(0)
      expect(map.tick_at(1, 0)).to eq(0)
      expect(map.tick_at(2, 1)).to eq(1)
      expect(map.tick_at(2, 2)).to eq(0)
      expect { map.tick_at(0, 3) }.to raise_error(Aliens::OutOfBoundsError)
      expect { map.tick_at(6, 0) }.to raise_error(Aliens::OutOfBoundsError)
      expect { map.tick_at(6, 3) }.to raise_error(Aliens::OutOfBoundsError)
    end
  end

  describe "parsing map chars" do
    it "works with non-default chars" do
      alt_parser = Aliens::TickMapParser.new(tick_char: '1', empty_char: '0')
      map = alt_parser.parse("11000111")
      expect(map.x_size).to eq(8)
      expect(map.y_size).to eq(1)
      expect(map.tick_at(0)).to eq(1)
      expect(map.tick_at(2)).to eq(0)
    end

    it "processes bad chars as random" do
      expect { @map = parser.parse("--oo--O--") }.not_to raise_error
      expect(@map.tick_at(6)).to be >= 0
      expect(@map.tick_at(6)).to be <= 1
    end
  end
end
