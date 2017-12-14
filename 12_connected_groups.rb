require_relative 'lib/search'

neighbours = ARGF.to_h { |l|
  left, right = l.split('<->')
  [Integer(left), right.split(?,).map(&method(:Integer)).freeze]
}
# no freeze neighbours; search mutates

puts 0.step { |i|
  break i if neighbours.empty?

  _, seen = Search::bfs(neighbours.keys.first, neighbours, ->(_) { false })

  puts seen.size if seen.include?(0)

  neighbours.delete_if { |k, _| seen.include?(k) }
}
