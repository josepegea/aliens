# frozen_string_literal: true

require 'spec_helper'

describe Aliens::TickMapClip do
  let(:parser) { Aliens::TickMapParser.new }

  let(:orig_map) do
    data = <<~TEXT
      -----
      --o--
      -----
    TEXT
    parser.parse(data)
  end

  describe "clips correctly" do
    it "for the whole map" do
      map = Aliens::TickMapClip.new(orig_map, 0, 0, orig_map.x_size, orig_map.y_size)
      expect(map.x_size).to eq(orig_map.x_size)
      expect(map.y_size).to eq(orig_map.y_size)
      expect(map.tick_at(0, 0)).to eq(0)
      expect(map.tick_at(1, 1)).to eq(0)
      expect(map.tick_at(2, 1)).to eq(1)
    end

    it "for a subset" do
      map = Aliens::TickMapClip.new(orig_map, 1, 1, 3, 2)
      expect(map.x_size).to eq(3)
      expect(map.y_size).to eq(2)
      expect(map.tick_at(0, 0)).to eq(0)
      expect(map.tick_at(1, 0)).to eq(1)
      expect(map.tick_at(1, 1)).to eq(0)
    end

    it "for a clip of a clip" do
      first_map = Aliens::TickMapClip.new(orig_map, 1, 1, 4, 2)
      map = Aliens::TickMapClip.new(first_map, 1, 0, 2, 2)
      expect(map.x_size).to eq(2)
      expect(map.y_size).to eq(2)
      expect(map.tick_at(0, 0)).to eq(1)
      expect(map.tick_at(1, 0)).to eq(0)
      expect(map.tick_at(0, 1)).to eq(0)
    end
  end
end
