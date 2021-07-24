require 'spec_helper'
require 'aliens'
require 'pry'

describe 'TickMap' do
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
      map = Aliens::TickMap.new(blank)
      expect(map.x_size).to eq(0)
      expect(map.y_size).to eq(0)
    end

    it "for a single line map" do
      map = Aliens::TickMap.new(empty_line)
      expect(map.x_size).to eq(6)
      expect(map.y_size).to eq(1)
    end

    it "for a multiline map" do
      map = Aliens::TickMap.new(bulls_eye)
      expect(map.x_size).to eq(5)
      expect(map.y_size).to eq(3)
    end

    it "raises for an irregular map" do
      expect { map = Aliens::TickMap.new(irregular_map) }.to raise_error(Aliens::NonRectangularScanError)
    end
  end

  describe "accesses individual ticks" do
    it "for a single line map" do
      map = Aliens::TickMap.new(empty_line)
      expect(map.tick?(0)).to be(false)
      expect(map.tick?(1)).to be(false)
      expect(map.tick?(5)).to be(false)
      expect { map.tick?(6) }.to raise_error(Aliens::OutOfBoundsError)
      expect { map.tick?(0, 1) }.to raise_error(Aliens::OutOfBoundsError)
    end

    it "for a multiline map" do
      map = Aliens::TickMap.new(bulls_eye)
      expect(map.tick?(0)).to be(false)
      expect(map.tick?(1, 0)).to be(false)
      expect(map.tick?(2, 1)).to be(true)
      expect(map.tick?(2, 2)).to be(false)
      expect { map.tick?(0, 3) }.to raise_error(Aliens::OutOfBoundsError)
      expect { map.tick?(6, 0) }.to raise_error(Aliens::OutOfBoundsError)
      expect { map.tick?(6, 3) }.to raise_error(Aliens::OutOfBoundsError)
    end
  end

  describe "parsing map chars" do
    it "works with non-default chars" do
      map = Aliens::TickMap.new("11000111", tick_char: '1', empty_char: '0')
      expect(map.x_size).to eq(8)
      expect(map.y_size).to eq(1)
      expect(map.tick?(0)).to be(true)
      expect(map.tick?(2)).to be(false)
    end

    it "fails with bad chars" do
      expect { map = Aliens::TickMap.new("--oo--O--") }.to raise_error(Aliens::UnrecognizedCharInScanError)
    end
  end
end
