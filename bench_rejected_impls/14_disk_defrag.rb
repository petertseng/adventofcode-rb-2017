require_relative '../lib/knot_hash'
require_relative '../lib/search'
require_relative '../lib/union_find'

require 'benchmark'
require 'set'

bench_candidates = []

bench_candidates << def bfs_hash(grid)
  dir = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ].map(&:freeze).freeze
  grid = grid.map(&:dup)

  puts 0.step { |i|
    return i unless (row = grid.index(&:any?))

    col = grid[row].index(true)

    _, seen = Search::bfs([row, col], ->((r, c)) {
      dir.map { |dy, dx| [r + dy, c + dx] }.select { |n|
        n.all? { |nn| nn >= 0 } && grid.dig(*n)
      }
    }, ->(_) { false })

    seen.each { |y, x| grid[y][x] = false }
  }
end

bench_candidates << def bfs_set(grid)
  dir = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ].map(&:freeze).freeze

  starts = Set.new(grid.flat_map.with_index { |row, y|
    row.map.with_index { |cell, x| [y, x] if cell }.compact
  })

  0.step { |i|
    return i if starts.empty?

    _, seen = Search::bfs(starts.first, ->((r, c)) {
      dir.map { |dy, dx| [r + dy, c + dx] }.select { |n|
        n.all? { |nn| nn >= 0 } && grid.dig(*n)
      }
    }, ->(_) { false })

    starts -= seen
  }
end

bench_candidates << def union_find(grid)
  dir = [
    [1, 0],
    [0, 1],
  ].map(&:freeze).freeze

  used = grid.flat_map.with_index { |row, y|
    row.map.with_index { |cell, x| y * SIDELEN + x if cell }.compact
  }

  uf = UnionFind.new(used, storage: Array)

  used.each { |u|
    y, x = u.divmod(SIDELEN)
    dir.map { |dy, dx| [y + dy, x + dx] }.select { |n|
      grid.dig(*n)
    }.each { |ny, nx| uf.union(y * SIDELEN + x, ny * SIDELEN + nx) }
  }

  uf.num_sets
end

SIDELEN = 128

NIBBLE = (0...16).to_h { |x|
  bits = [8, 4, 2, 1].map { |bit| x & bit != 0 }
  [x.to_s(16), bits.freeze]
}.freeze

grid = (0...SIDELEN).map { |n|
  KnotHash::hash(
    "#{!ARGV.empty? && !File.exist?(ARGV.first) ? ARGV.first : ARGF.read}-#{n}".bytes + KnotHash::SUFFIX
  ).each_char.flat_map(&NIBBLE).freeze
}.freeze

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 10.times { results[f] = send(f, grid) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
