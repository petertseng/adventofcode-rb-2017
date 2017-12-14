require_relative 'lib/knot_hash'
require_relative 'lib/union_find'

GRID = 128

grid = (0...GRID).map { |n|
  KnotHash::hash(
    "#{!ARGV.empty? && !File.exist?(ARGV.first) ? ARGV.first : ARGF.read}-#{n}".bytes + KnotHash::SUFFIX
  ).to_i(16).to_s(2).rjust(GRID, ?0).each_char.map { |x| x == ?1 }
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
