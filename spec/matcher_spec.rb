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

  let(:alien_1) do
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

  let(:reading_1) do
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

  let(:reading_2) do
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

  let(:reading_3) do
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

  let(:reading_4) do
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
      expect(subject.match(alien_1, alien_1)).to eq(1)
    end
  end

  describe "opposite matches" do
    it "rejects empty to full" do
      expect(subject.match(all_blank, all_ticks)).to eq(0)
    end
  end

  describe "fuzzy matches" do
    let(:thereshold) { 0.85 }

    it "orders aliens by closeness" do
      reading_1_score = subject.match(alien_1, reading_1)
      reading_2_score = subject.match(alien_1, reading_2)
      reading_3_score = subject.match(alien_1, reading_3)
      reading_4_score = subject.match(alien_1, reading_4)
      expect(reading_1_score).to be >= reading_2_score
      expect(reading_2_score).to be >= reading_3_score
      expect(reading_3_score).to be >= reading_4_score
    end

    it "puts reasonable matches above thereshold" do
      reading_1_score = subject.match(alien_1, reading_1)
      reading_2_score = subject.match(alien_1, reading_2)
      expect(reading_1_score).to be > thereshold
      expect(reading_2_score).to be > thereshold
    end

    it "puts hard matches below thereshold" do
      reading_3_score = subject.match(alien_1, reading_3)
      reading_4_score = subject.match(alien_1, reading_4)
      expect(reading_3_score).to be < thereshold
      expect(reading_4_score).to be < thereshold
    end
  end
end
