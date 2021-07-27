module Aliens
  class Scanner
    attr_reader :alien_patterns
    attr_reader :minimum_confidence_factor
    attr_reader :edge_thereshold
    attr_reader :matcher
    attr_reader :clipper
    attr_reader :results_class

    def initialize(alien_patterns,
                   minimum_confidence_factor: 0.85,
                   edge_thereshold: 0.5,
                   clipper_class: Clipper, clipper: clipper_class.new,
                   matcher_class: Matcher, matcher: matcher_class.new,
                   results_class: Result
                  )
      @alien_patterns = alien_patterns
      @minimum_confidence_factor = minimum_confidence_factor
      @edge_thereshold = edge_thereshold
      @clipper = clipper
      @matcher = matcher
      @results_class = results_class
    end

    def scan(radar_reading)
      alien_patterns.map do |pattern|
        scan_for_pattern(radar_reading, pattern)
      end.flatten
    end

    private

    def scan_for_pattern(radar_reading, pattern)
      found_bandits = []
      y_scan_range(radar_reading, pattern).each do |y|
        x_scan_range(radar_reading, pattern).each do |x|
          bandit = match_pattern(radar_reading, pattern, x, y)
          found_bandits << bandit if bandit
        end
      end
      found_bandits
    end

    def x_scan_range(radar_reading, pattern)
      thereshold = (pattern.x_size * edge_thereshold).to_i
      (-thereshold .. radar_reading.x_size - thereshold)
    end

    def y_scan_range(radar_reading, pattern)
      thereshold = (pattern.y_size * edge_thereshold).to_i
      (-thereshold .. radar_reading.y_size - thereshold)
    end

    def match_pattern(radar_reading, pattern, x, y)
      # Let's clip for the real matching range
      x_offset, x_size = clip_range(x, radar_reading.x_size, pattern.x_size)
      y_offset, y_size = clip_range(y, radar_reading.y_size, pattern.y_size)
      pattern_clip = clipper.clip(pattern, x_offset, y_offset, x_size, y_size)
      reading_clip = clipper.clip(radar_reading, x + x_offset, y + y_offset, x_size, y_size)
      confidence_factor = matcher.match(pattern_clip, reading_clip)
      return nil unless confidence_factor >= minimum_confidence_factor
      results_class.new(x, y, confidence_factor, pattern, pattern_clip, reading_clip)
    end

    def clip_range(v, reading_size, pattern_size)
      offset = v < 0 ? v * -1 : 0
      excess = v + pattern_size - reading_size
      excess = 0 if excess < 0
      size = pattern_size - offset - excess
      return offset, size
    end
  end
end
