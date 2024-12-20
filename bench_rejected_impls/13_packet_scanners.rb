require 'benchmark'

bench_candidates = []

# For a given (depth, period) pair,
# we can determine a forbidden starting time:
# The starting time is NOT congruent to -depth modulo period.
# We combine all these forbidden times by period.
def forbidden_starts(periods)
  periods.group_by(&:last).to_h { |period, depths|
    [period, depths.map { |depth, _| -depth % period }.sort]
  }
end

# Expand smaller periods into larger ones, then remove the smaller ones.
# For example, 2 => [1], 8 => [2, 4, 6] would turn into:
# 8 => [2, 4, 6, 1, 3, 5, 7]
def absorb_periods(forbidden_starts)
  periods = forbidden_starts.keys.sort

  periods.each_with_index { |p1, i|
    expand_into = periods[(i + 1)..-1].select { |x| x % p1 == 0 }
    next if expand_into.empty?
    forbidden = forbidden_starts.delete(p1)
    expand_into.each { |p2|
      forbidden_starts[p2] |= (0...p2).select { |p| forbidden.include?(p % p1) }
    }
  }

  forbidden_starts
end

bench_candidates << def combine_singles_only(depths, periods)
  forbidden_starts = absorb_periods(forbidden_starts(periods))
  single_openings, other_periods = forbidden_starts.partition { |p, ds|
    ds.size == p - 1
  }

  # For any periods with only one opening, we can combine them into one big period,
  # and this big period also only has one opening!
  base, period = single_openings.sort_by(&:first).reverse.reduce([0, 1]) { |(b, p1), (p2, ds)|
    allowed_d = (0...p2).find { |d| !ds.include?(d) }
    b += p1 until b % p2 == allowed_d
    [b, p1.lcm(p2)]
  }

  base.step(by: period).find { |delay|
    # Now we only need to check all other periods.
    other_periods.all? { |p, ds| !ds.include?(delay % p) }
  }
end

bench_candidates << def combine_multis(depths, periods)
  absorb_periods(forbidden_starts(periods)).sort_by { |k, v|
    [k - v.size, -k]
  }.reduce([[0], 1]) { |(bs, p1), (p2, ds)|
    allowed_ds = (0...p2).to_a - ds
    [
      bs.product(allowed_ds).map { |b, allowed_d|
        b += p1 until b % p2 == allowed_d
        b
      },
      p1.lcm(p2)
    ]
  }.first.min
end

depths = ARGF.to_h { |x|
  x.scan(/\d+/).map(&method(:Integer)).freeze
}.freeze
periods = depths.to_h { |k, v| [k, 2 * (v - 1)] }.freeze

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 100.times { results[f] = send(f, depths, periods) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
