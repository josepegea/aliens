# frozen_string_literal: true

require 'thor'

module Aliens
  # CLI interface
  class CLI < Thor
    desc "scan", "Scan a radar reading looking for Aliens"
    option :minimum_confidence_factor, type: :numeric, aliases: 'c', default: 0.85

    def scan(reading = 'data/radar01.txt')
      alien_patterns = load_aliens
      aliens_scanner = Aliens::Scanner.new(alien_patterns,
                                           minimum_confidence_factor: options[:minimum_confidence_factor])
      radar_reading = parser.parse(File.read(reading))

      bandits = aliens_scanner.scan(radar_reading)

      show_results(bandits)
    end

    default_task :scan

    private

    def parser
      @parser ||= Aliens::TickMapParser.new
    end

    def load_aliens
      alien_patterns = []
      alien_patterns << parser.parse(File.read('data/alien01.txt'))
      alien_patterns << parser.parse(File.read('data/alien02.txt'))
      alien_patterns
    end

    def show_results(bandits)
      bandits.each do |bandit|
        puts bandit.to_s
      end
    end
  end
end
