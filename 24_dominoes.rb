def best(right, str, size, edges, loops)
  # Add in any loops:
  str += right * 2 * loops[right]
  size += loops[right]

  possible_nexts = edges[right].keys
  return [str + right, [size, str + right]] if possible_nexts.empty?

  saved_loops = loops.delete(right) || 0
  possible_nexts.map { |next_right|
    decrement(edges, next_right, right)
    decrement(edges, right, next_right)
    best(next_right, str + right * 2, size + 1, edges, loops).tap {
      edges[next_right][right] += 1
      edges[right][next_right] += 1
    }
  }.transpose.map(&:max).tap { loops[right] = saved_loops }
end

def decrement(edges, a, b)
  if edges[a][b] == 1
    edges[a].delete(b)
  else
    edges[a][b] -= 1
  end
end

edges = Hash.new { |h, k| h[k] = Hash.new(0) }
loops = Hash.new(0)

ARGF.each_line { |l|
  a, b = l.split(?/, 2).map(&method(:Integer))
  if a == b
    # Fewer recursive calls by treating all [X, X] dominoes specially.
    # Cuts runtime to about 1/7 of the original.
    loops[a] += 1
  else
    edges[a][b] += 1
    edges[b][a] += 1
  end
}

part1, (_, part2) = best(0, 0, 1, edges, loops)
puts part1
puts part2
