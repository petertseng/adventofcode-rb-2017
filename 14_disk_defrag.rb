require_relative 'lib/knot_hash'
require_relative 'lib/union_find'

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
  [1, 0],
  [0, 1],
].map(&:freeze).freeze

used = grid.flat_map.with_index { |row, y|
  row.map.with_index { |cell, x| y * GRID + x if cell }.compact
}

uf = UnionFind.new(used, storage: Array)

used.each { |u|
  y, x = u.divmod(GRID)
  DIR.map { |dy, dx| [y + dy, x + dx] }.select { |n|
    grid.dig(*n)
  }.each { |ny, nx| uf.union(y * GRID + x, ny * GRID + nx) }
}

puts uf.num_sets
