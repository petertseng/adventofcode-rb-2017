def dist(x, y)
  # If move NE then SE, you end up at (1, -1).
  # This requires 2 moves to get to, since there is no +1, -1 move.
  # Same if we are at (-1, 1) since there is no -1, +1 move.
  # Therefore:
  # If both coords are same sign, distance is the maximum magnitude.
  # If they are of different sign, distance is sum of magnitudes.
  #
  # NOTE that for my input, it was sufficient to always use max only!
  # So, I never had a situation where I was [+, -] or [-, +].
  x.positive? == y.positive? ? [x.abs, y.abs].max : x.abs + y.abs
end


x = 0
y = 0
maxdist = 0

(!ARGV.empty? && ARGV.first.include?(?,) ? ARGV.first : ARGF.read).split(?,) { |i|
  case i.strip
  when 'ne'
    y -= 1
  when 'sw'
    y += 1
  when 'nw'
    x -= 1
  when 'se'
    x += 1
  when 'n'
    y -= 1
    x -= 1
  when 's'
    y += 1
    x += 1
  else
    raise "unknown #{i}"
  end
  maxdist = [maxdist, dist(x, y)].max
}

puts dist(x, y)

puts maxdist
