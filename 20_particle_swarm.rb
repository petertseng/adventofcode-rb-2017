particles = ARGF.each_line.map { |l|
  l.scan(/-?\d+/).map(&:to_i).each_slice(3).to_a
}

# Max possible collision time.
max_t = 0
particles.combination(2) { |(p1, v1, a1), (p2, v2, a2)|
  times = [0, 1, 2].map { |i|
    # When will they collide in the ith dimension?
    # Because we change velocity before position:
    # 0.5a1t(t + 1) + v1t + p1 = 0.5a2t(t + 1) + v2t + p2
    # 0.5a1t^2 + v1t + 0.5a2t + p1 = 0.5a2t^2 + v2t + 0.5a2t + p2
    a = (a1[i] - a2[i]) / 2.0
    b = a + v1[i] - v2[i]
    c = p1[i] - p2[i]

    if a == 0 && b == 0
      # Do not collide.
      next [] if c != 0
      # May collide in this dimension at any time.
      nil
    elsif a == 0
      # Equal acceleration, only need to deal w/ vel and pos
      # v1t + p1 = v2t + p2
      [-c / b.to_f].reject(&:negative?)
    else
      d = b * b - 4 * a * c
      # discriminant -ve: these particles do not collide.
      next [] if d < 0
      [-1, 1].map { |s| (-b + s * (d ** 0.5)) / (2 * a) }.reject(&:negative?)
    end
  }.compact

  # If times.size == 0,
  # they collide at time 0 and do not affect simulation further.
  if times.size == 1
    max_t = [times.first, max_t].max
  elsif times.size > 0
    times[0].product(*times[1..-1]) { |xs|
      next unless xs.max == xs.min
      # Possible collision.
      max_t = [xs.max.ceil, max_t].max
    }
  end
}

# That only told us how long to run part 2...
# need different number for part 1
T = max_t * 10
# Simply comparing magnitudes is fraught with peril:
# p 0 0 0 v  1 0 0 a 1 0 0
# p 0 0 0 v -2 0 0 a 1 0 0
puts particles.each_with_index.min_by { |(p, v, a), _|
  # Note the T * (T + 1), rather than just T * T
  # because this is discrete, not continuous.
  p.zip(v, a).sum { |p0, v0, a0| (p0 + v0 * T + a0 * T * (T + 1) / 2).abs }
}.last

max_t.times {
  particles.each { |p, v, a|
    3.times { |i|
      v[i] += a[i]
      p[i] += v[i]
    }
  }
  particles = particles.group_by(&:first).select { |_, v|
    v.size == 1
  }.values.flatten(1)
}

puts particles.size
