depths = ARGF.each_line.to_h { |x|
  x.scan(/\d+/).map(&method(:Integer))
}.freeze

periods = depths.to_h { |k, v| [k, 2 * (v - 1)] }.freeze

puts periods.select { |k, v| k % v == 0 }.keys.sum { |k| k * depths[k] }

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

puts absorb_periods(forbidden_starts(periods)).sort_by { |k, v|
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
