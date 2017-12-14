require_relative 'lib/knot_hash'
require_relative 'lib/search'

GRID = 128

NIBBLE = (0...16).to_h { |x|
  bits = [8, 4, 2, 1].map { |bit| x & bit != 0 }
  [x.to_s(16), bits.freeze]
}.freeze

grid = (0...GRID).map { |n|
  KnotHash::hash(
    "#{!ARGV.empty? && !File.exist?(ARGV.first) ? ARGV.first : ARGF.read}-#{n}".bytes + KnotHash::SUFFIX
  ).each_char.flat_map(&NIBBLE)
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
