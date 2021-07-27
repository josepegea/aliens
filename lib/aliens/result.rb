# frozen_string_literal: true

module Aliens
  # Encapsulates a result match
  class Result
    attr_accessor :x, :y, :confidence_factor
    attr_accessor :pattern
    attr_accessor :pattern_clip, :reading_clip

    # Having a long list makes sense here
    # rubocop:disable Metrics/ParameterLists
    def initialize(x, y, confidence_factor, pattern, pattern_clip, reading_clip)
      @x = x
      @y = y
      @confidence_factor = confidence_factor
      @pattern = pattern
      @pattern_clip = pattern_clip
      @reading_clip = reading_clip
    end
    # rubocop:enable Metrics/ParameterLists

    # It's long because of the text
    # rubocop:disable Metrics/MethodLength
    def to_s
      res = <<~TEXT
        ==================================================================
        Found #{'partial ' if clipped_match?}bandit at [#{x}, #{y}] with #{@confidence_factor} confidence
        Original:
        #{pattern}

        Found:
        #{reading_clip}

      TEXT
      if clipped_match?
        res += <<~TEXT
          Portion:
          #{pattern_clip}
        TEXT
      end
      res
    end
    # rubocop:enable Metrics/MethodLength

    def clipped_match?
      pattern.x_size != pattern_clip.x_size || pattern.y_size != pattern_clip.y_size
    end
  end
end
