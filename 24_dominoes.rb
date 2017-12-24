def best(right, str, size, edges)
  possible_nexts = edges[right].keys
  return [str + right, [size, str + right]] if possible_nexts.empty?

  possible_nexts.map { |next_right|
    decrement(edges, next_right, right)
    decrement(edges, right, next_right)
    best(next_right, str + right * 2, size + 1, edges).tap {
      edges[next_right][right] += 1
      edges[right][next_right] += 1
    }
  }.transpose.map(&:max)
end

def decrement(edges, a, b)
  if edges[a][b] == 1
    edges[a].delete(b)
  else
    edges[a][b] -= 1
  end
end

edges = Hash.new { |h, k| h[k] = Hash.new(0) }

ARGF.each_line { |l|
  a, b = l.split(?/, 2).map(&method(:Integer))
  edges[a][b] += 1
  edges[b][a] += 1
}

part1, (_, part2) = best(0, 0, 1, edges)
puts part1
puts part2
