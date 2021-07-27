# frozen_string_literal: true

require 'pry'

require_relative 'lib/aliens'

alien_patterns = []

parser = Aliens::TickMapParser.new

alien_patterns << parser.parse(File.open('data/alien01.txt'))
alien_patterns << parser.parse(File.open('data/alien02.txt'))

aliens_scanner = Aliens::Scanner.new(alien_patterns)

radar_reading = parser.parse(File.open('data/radar01.txt'))

bandits = aliens_scanner.scan(radar_reading)

bandits.each do |bandit|
  puts bandit.to_s
end
