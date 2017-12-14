require_relative 'lib/union_find'

neighbours = ARGF.each_line.to_h { |l|
  left, right = l.split('<->')
  [Integer(left), right.split(?,).map(&method(:Integer))]
}

nodes = neighbours.keys

uf = UnionFind.new(nodes)
neighbours.each { |k, vs| vs.each { |v| uf.union(k, v) } }

zeros_parent = uf.find(0)
puts nodes.count { |x| uf.find(x) == zeros_parent }

puts nodes.map { |x| uf.find(x) }.uniq.size
