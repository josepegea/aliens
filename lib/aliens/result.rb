module Aliens
  class Result
    attr_accessor :x, :y, :confidence_factor
    attr_accessor :pattern
    attr_accessor :pattern_clip, :reading_clip

    def initialize(x, y, confidence_factor, pattern, pattern_clip, reading_clip)
      @x = x
      @y = y
      @confidence_factor = confidence_factor
      @pattern = pattern
      @pattern_clip = pattern_clip
      @reading_clip = reading_clip
    end

    def to_s
      <<~TEXT
        ------------------------------------------------------------------
        Found bandit at [#{x}, #{y}] with #{@confidence_factor} confidence
        Original:
        #{pattern}

        Portion:
        #{pattern_clip}

        Found:
        #{reading_clip}
        ------------------------------------------------------------------

      TEXT
    end
  end
end
