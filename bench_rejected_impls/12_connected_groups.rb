require_relative '../lib/search'
require_relative '../lib/union_find'

require 'benchmark'

bench_candidates = []

bench_candidates << def bfs(neighbours)
  0.step { |i|
    return i if neighbours.empty?

    _, seen = Search::bfs(neighbours.keys.first, neighbours, ->(_) { false })

    neighbours.delete_if { |k, _| seen.include?(k) }
  }
end

# we do have to union by size for day 12,
# but just for comparison:
bench_candidates << def union_find_rank(neighbours)
  nodes = neighbours.keys

  uf = UnionFind.new(nodes, storage: Array)
  neighbours.each { |k, vs| vs.each { |v| uf.union(k, v) } }

  uf.num_sets
end

bench_candidates << def union_find_sz(neighbours)
  nodes = neighbours.keys

  uf = UnionFind.new(nodes, storage: Array)
  neighbours.each { |k, vs| vs.each { |v| uf.union_sz(k, v) } }

  uf.num_sets
end

neighbours = ARGF.to_h { |l|
  left, right = l.split('<->')
  [Integer(left), right.split(?,).map(&method(:Integer)).freeze]
}.freeze

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 100.times { results[f] = send(f, neighbours.dup) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
