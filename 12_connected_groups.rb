require_relative 'lib/union_find'

neighbours = ARGF.to_h { |l|
  left, right = l.split('<->')
  [Integer(left), right.split(?,).map(&method(:Integer)).freeze]
}
# no freeze neighbours; search mutates

nodes = neighbours.keys

uf = UnionFind.new(nodes)
neighbours.each { |k, vs| vs.each { |v| uf.union_sz(k, v) } }

puts uf.size(0)
puts uf.num_sets
