# frozen_string_literal: true

require 'spec_helper'

describe Aliens::Matcher do
  let(:parser) { Aliens::TickMapParser.new }

  let(:all_blank) do
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

  let(:all_ticks) do
    pattern = <<~TEXT
      ooooooooooo
      ooooooooooo
      ooooooooooo
      ooooooooooo
      ooooooooooo
      ooooooooooo
      ooooooooooo
      ooooooooooo
    TEXT
    parser.parse(pattern)
  end

  let(:alien1) do
    pattern = <<~TEXT
      --o-----o--
      ---o---o---
      --ooooooo--
      -oo-ooo-oo-
      ooooooooooo
      o-ooooooo-o
      o-o-----o-o
      ---oo-oo---
    TEXT
    parser.parse(pattern)
  end

  let(:reading1) do
    pattern = <<~TEXT
      --o-----o--
      ---o---o---
      --ooOoooo--
      -oo-ooo-oo-
      ooo-ooooooo
      o-ooooooo-o
      o-o---o-o-o
      ---oo-oo---
    TEXT
    parser.parse(pattern)
  end

  let(:reading2) do
    pattern = <<~TEXT
      --oo----o--
      -------o---
      o--oooooo--
      -oo--oo--o-
      oo-oooooooo
      o-ooooooo-o
      oo-o----o-o
      --ooo-oo--o
    TEXT
    parser.parse(pattern)
  end

  let(:reading3) do
    pattern = <<~TEXT
      --oo----o--
      -------o---
      -------o---
      o--o-o-oo--
      -oo--oo--o-
      oo-ooOoo-oo
      oo-o----o-o
      --ooo-oo--o
    TEXT
    parser.parse(pattern)
  end

  let(:reading4) do
    pattern = <<~TEXT
      ooooooooooo
      ooooooooooo
      ooooooooooo
      ooooooooooo
      oo---------
      -----------
      -----------
      -----------
    TEXT
    parser.parse(pattern)
  end

  describe "exact matches" do
    it "matches empty to empty" do
      expect(subject.match(all_blank, all_blank)).to eq(1)
    end

    it "matches full to full" do
      expect(subject.match(all_ticks, all_ticks)).to eq(1)
    end

    it "matches alien to itself" do
      expect(subject.match(alien1, alien1)).to eq(1)
    end
  end

  describe "opposite matches" do
    it "rejects empty to full" do
      expect(subject.match(all_blank, all_ticks)).to eq(0)
    end
  end

  describe "fuzzy matches" do
    let(:threshold) { 0.85 }

    it "orders aliens by closeness" do
      reading1_score = subject.match(alien1, reading1)
      reading2_score = subject.match(alien1, reading2)
      reading3_score = subject.match(alien1, reading3)
      reading4_score = subject.match(alien1, reading4)
      expect(reading1_score).to be >= reading2_score
      expect(reading2_score).to be >= reading3_score
      expect(reading3_score).to be >= reading4_score
    end

    it "puts reasonable matches above threshold" do
      reading1_score = subject.match(alien1, reading1)
      reading2_score = subject.match(alien1, reading2)
      expect(reading1_score).to be > threshold
      expect(reading2_score).to be > threshold
    end

    it "puts hard matches below threshold" do
      reading3_score = subject.match(alien1, reading3)
      reading4_score = subject.match(alien1, reading4)
      expect(reading3_score).to be < threshold
      expect(reading4_score).to be < threshold
    end
  end
end
