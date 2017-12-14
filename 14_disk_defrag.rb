require_relative 'lib/knot_hash'
require_relative 'lib/search'

GRID = 128

grid = (0...GRID).map { |n|
  KnotHash::hash(
    "#{!ARGV.empty? && !File.exist?(ARGV.first) ? ARGV.first : ARGF.read}-#{n}".bytes + KnotHash::SUFFIX
  ).to_i(16).to_s(2).rjust(GRID, ?0).each_char.map { |x| x == ?1 }
}

puts grid.sum { |row| row.count(true) }

DIR = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1],
].map(&:freeze).freeze

puts 0.step { |i|
  break i unless (row = grid.index(&:any?))

  col = grid[row].index(true)

  _, seen = Search::bfs([row, col], ->((r, c)) {
    DIR.map { |dy, dx| [r + dy, c + dx] }.select { |n|
      n.all? { |nn| nn >= 0 } && grid.dig(*n)
    }
  }, ->(_) { false })

  seen.each { |y, x| grid[y][x] = false }
}
