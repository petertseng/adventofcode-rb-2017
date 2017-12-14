require_relative 'lib/union_find'

neighbours = ARGF.each_line.to_h { |l|
  left, right = l.split('<->')
  [Integer(left), right.split(?,).map(&method(:Integer))]
}

nodes = neighbours.keys

uf = UnionFind.new(nodes)
neighbours.each { |k, vs| vs.each { |v| uf.union_sz(k, v) } }

puts uf.size(0)
puts uf.num_sets
