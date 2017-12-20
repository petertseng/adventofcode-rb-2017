particles = ARGF.map { |l|
  l.scan(/-?\d+/).map(&method(:Integer)).each_slice(3).map(&:freeze).freeze
}.freeze

# Pick an arbitrary large time and hope it gives the right result?
T = 10000
# Simply comparing magnitudes is fraught with peril:
# p 0 0 0 v  1 0 0 a 1 0 0
# p 0 0 0 v -2 0 0 a 1 0 0
puts particles.each_with_index.min_by { |(p, v, a), _|
  # Note the T * (T + 1), rather than just T * T
  # because this is discrete, not continuous.
  p.zip(v, a).sum { |p0, v0, a0| (p0 + v0 * T + a0 * T * (T + 1) / 2).abs }
}.last

GIVE_UP_AFTER = 20
cycles_since_last_collision = 0
last_size = particles.size

# TODO: should I detect when we're overflowing compression?
half_coord = 1 << 19
compress = ->((x, y, z)) {
  (x + half_coord) << 40 | (y + half_coord) << 20 | z + half_coord
}
particles = particles.map { |part| part.map(&compress) }.freeze

puts loop {
  particles.each { |part|
    part[1] += part[2]
    part[0] += part[1]
  }
  particles = particles.group_by(&:first).select { |_, v|
    v.size == 1
  }.values.flatten(1)
  cycles_since_last_collision = 0 if particles.size != last_size
  break particles.size if (cycles_since_last_collision += 1) > GIVE_UP_AFTER
  last_size = particles.size
}
