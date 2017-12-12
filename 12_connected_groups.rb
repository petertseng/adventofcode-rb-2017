require 'set'

neighbours = ARGF.each_line.to_h { |l|
  left, right = l.split('<->')
  [Integer(left), right.split(?,).map(&method(:Integer))]
}

puts 0.step { |i|
  break i if neighbours.empty?

  queue = [neighbours.keys.first]
  seen = Set.new

  while (n = queue.pop)
    next if seen.include?(n)
    seen << n
    queue.concat(neighbours[n])
  end

  puts seen.size if seen.include?(0)

  neighbours.delete_if { |k, _| seen.include?(k) }
}
