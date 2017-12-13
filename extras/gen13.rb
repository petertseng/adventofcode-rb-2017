POWER_OF_TWO = 64

# Select a residue for each of these moduli.
# For these moduli, only one residue will be allowed.
dense_moduli = [5, 7, 9, 11, 13, 17, POWER_OF_TWO].map { |p| [p, rand(p)] }

base, step = dense_moduli.reduce([0, 1]) { |(b, p1), (p2, m)|
  b += p1 until b % p2 == m
  [b, p1.lcm(p2)]
}

# We'll add another modulus that allows more than one residue.
# We'll carefully pick the residues it forbids:
sparse_modulus = 19 * 2
steps_needed = 2
sparse_eliminate = steps_needed.times.map { |n|
  (base + step * n) % sparse_modulus
}
answer = base + step * steps_needed

# Based on the residue that each of the dense moduli *allows*,
# now we generate the list that each must *forbid*.
eliminate = dense_moduli.flat_map { |f, _|
  f *= 2
  elim = (0...f).reject { |x| x & 1 != answer & 1 || answer % f == x }
  forbid = []

  # We divide by 3 if possible (for 9) so that we can compact the input.
  # For example, if 9 is supposed to forbid 0, 2, 3, 4, 5, 6, 7, 8
  # we can express this as:
  # * 3 forbids 0 and 2
  # * 9 forbids 4 and 7 (with 3, 6, 5, 8 being implicit from the 3).
  # Same with dividing by 2 for the power of 2.
  reduce_by = ->(factor) {
    while f % factor == 0
      new_f = f / factor
      new_elim = (0...new_f).select { |x| (0...factor).all? { |n| elim.include?(x + new_f * n) } }
      forbid << [f, elim - (0...factor).flat_map { |n| new_elim.map { |x| x + new_f * n } }]
      f = new_f
      elim = new_elim
    end
  }

  reduce_by[3]

  if f == POWER_OF_TWO * 2
    reduce_by[2]
    # at this point f is 1,
    # so we're not going to add it.
  else
    forbid << [f, elim]
  end

  forbid
}.to_h.merge(2 => [answer.even? ? 1 : 0], sparse_modulus => sparse_eliminate)

STDERR.puts(answer)
STDERR.puts(eliminate)

eliminate.flat_map { |k, vs| vs.map { |v| [k, v] } }.shuffle.each_with_object({}) { |(period, forbid), h|
  # We'll just greedily take the first depth that lets this scanner forbid this residue.
  depth = -forbid % period
  depth += period while h.has_key?(depth)
  h[depth] = period / 2 + 1
}.sort_by(&:first).each { |k, v| puts "#{k}: #{v}" }
