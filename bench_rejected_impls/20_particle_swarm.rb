require 'benchmark'

bench_candidates = []

bench_candidates << def fixed_time(particles)
  give_up_after = 20
  cycles_since_last_collision = 0
  last_size = particles.size
  loop {
    particles.each { |p, v, a|
      3.times { |i|
        v[i] += a[i]
        p[i] += v[i]
      }
    }
    particles = particles.group_by(&:first).select { |_, v|
      v.size == 1
    }.values.flatten(1)
    cycles_since_last_collision = 0 if particles.size != last_size
    return particles.size if (cycles_since_last_collision += 1) > give_up_after
    last_size = particles.size
  }
end

bench_candidates << def compress(particles)
  give_up_after = 20
  cycles_since_last_collision = 0
  last_size = particles.size
  half_coord = 1 << 19
  compress = ->((x, y, z)) {
    (x + half_coord) << 40 | (y + half_coord) << 20 | z + half_coord
  }
  particles.map! { |pva| pva.map(&compress) }

  loop {
    particles.each { |part|
      part[1] += part[2]
      part[0] += part[1]
    }
    particles = particles.group_by(&:first).select { |_, v|
      v.size == 1
    }.values.flatten(1)
    cycles_since_last_collision = 0 if particles.size != last_size
    return particles.size if (cycles_since_last_collision += 1) > give_up_after
    last_size = particles.size
  }
end

slow_bench_candidates = []
# too slow (1000 particles means 499500 pairs)
slow_bench_candidates << def detect_time(particles)
  # Max possible collision time.
  # Calculating this collision time just takes too long.
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

  particles.size
end

particles = ARGF.map { |l|
  l.scan(/-?\d+/).map(&method(:Integer)).each_slice(3).map(&:freeze).freeze
}.freeze

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 10.times { results[f] = send(f, particles.map { |p| p.map(&:dup) }) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end

puts "slow (only run 1x instead of 10x!)"

Benchmark.bmbm { |bm|
  slow_bench_candidates.each { |f|
    bm.report(f) { 1.times { results[f] = send(f, particles.map { |p| p.map(&:dup) }) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
