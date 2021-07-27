# frozen_string_literal: true

require 'spec_helper'

describe Aliens::TickMappable do
  let(:parser) { Aliens::TickMapParser.new }

  let(:alien_pattern) do
    <<~TEXT
      --o-----o--
      ---o---o---
      --ooooooo--
      -oo-ooo-oo-
      ooooooooooo
      o-ooooooo-o
      o-o-----o-o
      ---oo-oo---
    TEXT
  end

  let(:alien) do
    parser.parse(alien_pattern)
  end

  describe "to_s" do
    it "prints the correct pattern" do
      expect(alien.to_s.chomp).to eq(alien_pattern.chomp)
    end
  end

  describe "iterators" do
    it "each_x" do
      expect(alien.each_x.to_a).to eq((0..alien.x_size - 1).to_a)
    end

    it "each_y" do
      expect(alien.each_y.to_a).to eq((0..alien.y_size - 1).to_a)
    end
  end
end
